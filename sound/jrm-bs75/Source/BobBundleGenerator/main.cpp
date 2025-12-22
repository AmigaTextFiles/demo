#include <QCoreApplication>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QImage>
#include <QFile>
#include <QDebug>
#include <cmath>
#include <cstring>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    QTextStream standardError(stderr);

    // Parse command line options
    QCommandLineParser parser;
    parser.setApplicationDescription("Bob Bundle Generator");
    parser.addHelpOption();
    parser.addVersionOption();

    QStringList args;
    for (int i = 0; i < argc; i++) {
        args << argv[i];
    }
    QCommandLineOption interleavedOption(QStringList() << "i" << "interleaved", QCoreApplication::translate("main", "Interleave bitplanes."));
    parser.addOption(interleavedOption);
    parser.addPositionalArgument("input", QCoreApplication::translate("main", "The name of the image to be converted."));
    parser.addPositionalArgument("output", QCoreApplication::translate("main", "The name of the generated bundle."));
    parser.process(args);

    bool interleave = parser.isSet(interleavedOption);

    const QStringList positionalArguments = parser.positionalArguments();

    if (positionalArguments.count() != 2) {
        standardError << QCoreApplication::translate("main", "Invalid arguments") << "\n";
        return 1;
    }

    QImage image(positionalArguments.first());
    if (image.colorCount() == 0) {
        standardError << QCoreApplication::translate("main", "Not a paletted image") << "\n";
        return 1;
    }

    standardError << QCoreApplication::translate("main", "Input image:\n");
    standardError << QCoreApplication::translate("main", "Size ") << image.width() << "x" << image.height() << "\n";
    standardError << QCoreApplication::translate("main", "Colors ") << image.colorCount() << "\n";

    QString outputFileName = positionalArguments.last();

    int bitplanes = 0;
    for (int colors = image.colorCount() - 1; colors > 0; colors >>= 1) {
        bitplanes++;
    }

    standardError << QCoreApplication::translate("main", "Output image:\n");
    standardError << QCoreApplication::translate("main", "Bitplanes ") << bitplanes << "\n";
    standardError << QCoreApplication::translate("main", "Name ") << outputFileName << "\n";

    QVector<int> scaleToWidths = { 4, 8, 16, 24, 32, 40, 48, 64, 80, 96, 112, 128, 144, 160, 176, 192, 208, 224, 240, 256 };
    for (int widthIndex = 0;; widthIndex++) {
        if (scaleToWidths[widthIndex] >= image.width()) {
            scaleToWidths.resize(widthIndex);
            break;
        }
    }
    scaleToWidths.append(image.width());

    QByteArray metadata;
    metadata.append(static_cast<char>(scaleToWidths.size() >> 8));
    metadata.append(static_cast<char>(scaleToWidths.size()));
    metadata.append(static_cast<char>(bitplanes >> 8));
    metadata.append(static_cast<char>(bitplanes));

    QByteArray images;
    for (int scaleToWidth : scaleToWidths) {
        QImage scaledImage = scaleToWidth != image.width() ? image.scaledToWidth(scaleToWidth) : image;
        /*
        QImage scaledImage = image;
        if (scaleToWidth != image.width()) {
            int scaleToHeight = image.height() * scaleToWidth / image.width();
            scaledImage = QImage(scaleToWidth, scaleToHeight, image.format());
            scaledImage.setColorTable(image.colorTable());
            for (int y = 0; y < scaleToHeight; y++) {
                for (int x = 0; x < scaleToWidth; x++) {
                    scaledImage.setPixel(x, y, image.pixelIndex(x * image.width() / scaleToWidth, y * image.width() / scaleToWidth));
                }
            }
        }
        */
        scaledImage.save(QString("wtf %1.png").arg(scaleToWidth));

        metadata.append(static_cast<char>(images.size() >> 24));
        metadata.append(static_cast<char>(images.size() >> 16));
        metadata.append(static_cast<char>(images.size() >> 8));
        metadata.append(static_cast<char>(images.size()));
        metadata.append(static_cast<char>(scaledImage.width() >> 8));
        metadata.append(static_cast<char>(scaledImage.width()));
        metadata.append(static_cast<char>(scaledImage.height() >> 8));
        metadata.append(static_cast<char>(scaledImage.height()));

        int width = (scaledImage.width() + 31) & 0xfff0;
        int height = scaledImage.height();

        int lineWidth = width / 8;
        int bitplaneDelta = interleave ? lineWidth : (lineWidth * height);
        int lineDelta = interleave ? (lineWidth * bitplanes) : lineWidth;

        standardError << QCoreApplication::translate("main", "Size ") << scaledImage.width() << "x" << scaledImage.height() << QCoreApplication::translate("main", " padded to ") << width << "x" << height << QCoreApplication::translate("main", " at offset ") << images.size() << "\n";

        int dataSize = lineWidth * height * bitplanes;
        unsigned char *data = new unsigned char[dataSize];
        memset(data, 0, dataSize);

        for (int y = 0; y < height; y++) {
            for (int x = 0; x < scaledImage.width(); x++) {
                unsigned char bit = 0x80 >> (x & 7);
                int pixel = scaledImage.pixelIndex(x, y);

                if (pixel > 0) {
                    for (int bitplane = 0; bitplane < bitplanes; bitplane++) {
                        data[bitplane * bitplaneDelta + y * lineDelta + x / 8] |= (pixel & (1 << bitplane)) ? bit : 0;
                    }
                }
            }
        }

        images.append(reinterpret_cast<char *>(data), dataSize);
        delete [] data;
    }
    standardError << QCoreApplication::translate("main", "Data size ") << images.size() << "\n";

    QFile file(outputFileName);
    file.open(QIODevice::WriteOnly);
    file.write(metadata);
    file.write(images);
    file.close();

    return 0;
}
