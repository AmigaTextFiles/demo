#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QSettings>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class QGraphicsScene;
class QGraphicsPixmapItem;

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(const QByteArray &data, QWidget *parent = nullptr);
    ~MainWindow() override;

protected:
    bool eventFilter(QObject *obj, QEvent *ev) override;

private slots:
    void createImage();
    void updateImage();
    void saveImage();
    void saveSettingsAndQuit();

private:
    Ui::MainWindow *ui;
    QSettings settings;
    QGraphicsScene *scene;
    QGraphicsPixmapItem *pixmapItem;
    QImage image;
    QByteArray data;
};

#endif // MAINWINDOW_H
