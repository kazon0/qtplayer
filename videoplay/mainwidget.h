#ifndef MAINWIDGET_H
#define MAINWIDGET_H

#include <QWidget>
#include <QLabel>
#include <QPixmap>
#include <QPushButton>
#include <QDebug>
#include <QThread>
#include "decodevideo.h"
#include "encodevideo.h"

class MainWidget :public QWidget
{
    Q_OBJECT
public:
    MainWidget(QWidget *parent = 0);
    ~MainWidget();
    void initUI();
private:
    QPushButton *btn;
    DecodeVideo * decodeThread;
    encodeVideo * encodeThread;
    QImage image;
    QLabel * lab;
public slots:
    void btnClickFunction();
    void recieveImage(QImage img);

protected:
    void paintEvent(QPaintEvent *event);

};

#endif // MAINWIDGET_H
