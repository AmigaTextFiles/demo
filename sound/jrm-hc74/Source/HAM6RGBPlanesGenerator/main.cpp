#include <QCoreApplication>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QImage>
#include <QDebug>
#include <cmath>
#include <cstring>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    QTextStream standardError(stderr);

    // Parse command line options
    QCommandLineParser parser;
    parser.setApplicationDescription("HAM6 RGB Planes Converter");
    parser.addHelpOption();
    parser.addVersionOption();

    QStringList args;
    for (int i = 0; i < argc; i++) {
        args << argv[i];
    }
    QCommandLineOption rgbOption(QStringList() << "3" << "rgb", QCoreApplication::translate("main", "RGB pattern."));
    parser.addOption(rgbOption);
    QCommandLineOption interleavedOption(QStringList() << "i" << "interleaved", QCoreApplication::translate("main", "Interleave bitplanes."));
    parser.addOption(interleavedOption);
    parser.addPositionalArgument("input", QCoreApplication::translate("main", "The name of the image to be converted."));
    parser.addPositionalArgument("output", QCoreApplication::translate("main", "The basename of the converted image."));
    parser.process(args);

    bool interleave = parser.isSet(interleavedOption);

    const QStringList positionalArguments = parser.positionalArguments();

    if (positionalArguments.count() != 2) {
        standardError << QCoreApplication::translate("main", "Invalid arguments") << "\n";
        return 1;
    }

    QImage image(positionalArguments.first());
    standardError << QCoreApplication::translate("main", "Input image:\n");
    standardError << QCoreApplication::translate("main", "Size ") << image.width() << "x" << image.height() << "\n";

    int width = (image.width() + 15) & 0xfff0;
    int height = image.height();
    int bitplanes = 4;

    int lineWidth = width / 8;
    int bitplaneDelta = interleave ? lineWidth : (lineWidth * height);
    int lineDelta = interleave ? (lineWidth * bitplanes) : lineWidth;

    int channelCount = parser.isSet(rgbOption) ? 3 : 4;

    QString outputFileName = QString("%1-%2-%3x%4x%5%6.raw").arg(positionalArguments.last()).arg(channelCount == 3 ? "rgb" : "rgbg").arg(width).arg(height).arg(bitplanes).arg(interleave ? "-interleaved" : "");

    standardError << QCoreApplication::translate("main", "Output image:\n");
    standardError << QCoreApplication::translate("main", "Bitplanes ") << bitplanes << "\n";
    standardError << QCoreApplication::translate("main", "Name ") << outputFileName << "\n";
    standardError << QCoreApplication::translate("main", "Channels ") << (channelCount == 3 ? "RGB" : "RGBG") << "\n";

    unsigned char *data = new unsigned char[lineWidth * height * bitplanes];
    memset(data, 0, lineWidth * height * bitplanes);

    const int shifts[4] = { 20, 12, 4, 12 };

    for (int y = 0; y < height; y++) {
        for (int x = 0; x < image.width(); x++) {
            QRgb rgb = image.pixel(x, y);
            unsigned char pixel = (rgb >> shifts[x % channelCount]) & 15;
            unsigned char bit = 0x80 >> (x & 7);

            if (pixel > 0) {
                for (int bitplane = 0; bitplane < bitplanes; bitplane++) {
                    data[bitplane * bitplaneDelta + y * lineDelta + x / 8] |= (pixel & (1 << bitplane)) ? bit : 0;
                }
            }
        }
    }

    FILE *file = fopen(outputFileName.toUtf8().constData(), "w");
    fwrite(data, 1, lineWidth * height * bitplanes, file);
    fclose(file);

    return 0;
}
