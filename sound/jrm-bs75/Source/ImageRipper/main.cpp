#include "mainwindow.h"

#include <QApplication>
#include <QFile>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    if (argc < 2) {
        return -1;
    }

    QByteArray data;
    if (argc == 2) {
        QFile input(argv[1]);
        input.open(QIODevice::ReadOnly);
        data = input.readAll();
    } else if (argc == 3) {
        QFile input1(argv[1]);
        QFile input2(argv[2]);
        input1.open(QIODevice::ReadOnly);
        input2.open(QIODevice::ReadOnly);
        QByteArray data1 = input1.readAll();
        QByteArray data2 = input2.readAll();
        for (int i = 0; i < qMax(data1.size(), data2.size()); i++) {
            if (i < data2.size()) {
                data.append(data2[i]);
            }
            if (i < data1.size()) {
                data.append(data1[i]);
            }
        }
    }

    MainWindow w(data);
    w.show();
    return a.exec();
}
