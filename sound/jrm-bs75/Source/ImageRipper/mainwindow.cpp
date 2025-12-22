#include <QGraphicsScene>
#include <QGraphicsPixmapItem>
#include <QGraphicsSceneMouseEvent>
#include <QFileDialog>
#include <QImageWriter>
#include <QMessageBox>
#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(const QByteArray &data, QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow),
      scene(new QGraphicsScene(this)),
      pixmapItem(new QGraphicsPixmapItem),
      data(data)
{
    ui->setupUi(this);
    pixmapItem->setShapeMode(QGraphicsPixmapItem::BoundingRectShape);
    scene->addItem(pixmapItem);
    scene->installEventFilter(this);
    ui->graphicsView->setStyleSheet( "QGraphicsView { border-style: none; }" );
    ui->graphicsView->setScene(scene);
    ui->graphicsView->scale(2, 2);

    ui->spinBoxOffset->setValue(settings.value("offset", 0).toInt());
    ui->spinBoxBitsPerPixel->setValue(settings.value("bitsPerPixel", 4).toInt());
    ui->spinBoxWidth->setValue(settings.value("width", 64).toInt());
    ui->spinBoxHeight->setValue(settings.value("height", 64).toInt());
    ui->spinBoxModulo->setValue(settings.value("modulo", 0).toInt());
    ui->lineEditOutput->setText(settings.value("output", "").toString());

    connect(ui->actionFileSave, SIGNAL(triggered()), this, SLOT(saveImage()));
    connect(ui->actionFileQuit, SIGNAL(triggered()), this, SLOT(saveSettingsAndQuit()));
    connect(ui->spinBoxWidth, SIGNAL(valueChanged(int)), this, SLOT(createImage()));
    connect(ui->spinBoxHeight, SIGNAL(valueChanged(int)), this, SLOT(createImage()));
    connect(ui->spinBoxOffset, SIGNAL(valueChanged(int)), this, SLOT(updateImage()));
    connect(ui->spinBoxBitsPerPixel, SIGNAL(valueChanged(int)), this, SLOT(createImage()));
    connect(ui->spinBoxModulo, SIGNAL(valueChanged(int)), this, SLOT(updateImage()));

    createImage();
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::createImage()
{
    image = QImage(ui->spinBoxWidth->value(), ui->spinBoxHeight->value(), QImage::Format_Indexed8);

    QVector<QRgb> colors;
    uint colorCount = 1 << ui->spinBoxBitsPerPixel->value();
    QRgb colorDelta = 0xffffff / (colorCount - 1);
    QRgb color = colorDelta;
//    qWarning("COUNT %d DELTA %x", colorCount, colorDelta);
    for (uint i = 1; i < colorCount; i++, color += colorDelta) {
//        colors.append(0xff000000 | color);
//        qWarning("COLOR %d IS %x", i, (0xff000000 | color));
    }
//    colors.prepend(0xff000000);
    colors.append(0x00000000);
    colors.append(0xffa4b5a4);
    colors.append(0xff0084f7);
    colors.append(0xfff73100);
    colors.append(0xfff7f7f7);
    colors.append(0xff0000a4);
    colors.append(0xffc50000);
    colors.append(0xffd6d6d6);
    colors.append(0xfff79400);
    colors.append(0xffa4b5a4);
    colors.append(0xff424242);
    colors.append(0xff212121);
    colors.append(0xff848484);
    colors.append(0xff840000);
    colors.append(0xfff73100);
    colors.append(0x00ffffff);
    image.setColorTable(colors);

    updateImage();
}

void MainWindow::updateImage()
{
    int offset = ui->spinBoxOffset->value();
    int bitsPerPixel = ui->spinBoxBitsPerPixel->value();
    uchar mask = static_cast<uchar>(((1 << bitsPerPixel) - 1) << (8 - bitsPerPixel));
    uchar currentMask = mask;
    int currentShift = 8 - bitsPerPixel;
//    qWarning("INITIAL BPL %d MASK %x", bitsPerPixel, mask);
    for (int y = 0; y < ui->spinBoxHeight->value(); y++) {
        for (int x = 0; x < ui->spinBoxWidth->value(); x++) {
            uchar pixel = (static_cast<uchar>(data[offset]) & currentMask) >> currentShift;
            if (pixel == 0x0f) {
                pixel = 0;
            }
//            qWarning("X %d Y %d OFFSET %d DATA %x MASK %x SHIFT %d PIXEL %x", x, y, offset, static_cast<uint>(data[offset]), static_cast<uint>(currentMask), currentShift, static_cast<uint>(pixel));
            image.setPixel(x, y, pixel);
            currentMask >>= bitsPerPixel;
            currentShift -= bitsPerPixel;
            if (!currentMask) {
                currentMask = mask;
                currentShift = 8 - bitsPerPixel;
                offset++;
            }
        }
        for (int x = 0; x < ui->spinBoxModulo->value(); x++) {
            currentMask >>= bitsPerPixel;
            currentShift -= bitsPerPixel;
            if (!currentMask) {
                currentMask = mask;
                currentShift = 8 - bitsPerPixel;
                offset++;
            }
        }
    }
    pixmapItem->setPixmap(QPixmap::fromImage(image));
}

void MainWindow::saveImage()
{
    QString path = ui->lineEditOutput->text();

    if (!path.isEmpty()) {
        QImageWriter imageWriter(path);
        if (imageWriter.write(image)) {
            ui->statusBar->showMessage(QString("Wrote to %1").arg(path));
        } else {
            ui->statusBar->showMessage(imageWriter.errorString());
        }
    }
}

void MainWindow::saveSettingsAndQuit()
{
    settings.setValue("offset", ui->spinBoxOffset->value());
    settings.setValue("bitsPerPixel", ui->spinBoxBitsPerPixel->value());
    settings.setValue("width", ui->spinBoxWidth->value());
    settings.setValue("height", ui->spinBoxHeight->value());
    settings.setValue("modulo", ui->spinBoxModulo->value());
    settings.setValue("output", ui->lineEditOutput->text());

    qApp->quit();
}

bool MainWindow::eventFilter(QObject *obj, QEvent *ev)
{
    if (obj == scene && ev->type() == QEvent::GraphicsSceneMousePress) {
        QGraphicsSceneMouseEvent *event = static_cast<QGraphicsSceneMouseEvent *>(ev);
        switch (event->button()) {
        case Qt::LeftButton: {
            int x = static_cast<int>(event->scenePos().x());
            int y = static_cast<int>(event->scenePos().y());
            if (x >= 0 && x < ui->spinBoxWidth->value()) {
                int offset = (y * (ui->spinBoxWidth->value() + ui->spinBoxModulo->value()) + x) * ui->spinBoxBitsPerPixel->value() / 8;
                ui->spinBoxOffset->setValue(ui->spinBoxOffset->value() + offset);
            }
            break;
        }
        case Qt::RightButton: {
            int y = static_cast<int>(event->scenePos().y());
            ui->spinBoxHeight->setValue(y);
            break;
        }
        default:
            break;
        }
    }
    return QMainWindow::eventFilter(obj, ev);
}
