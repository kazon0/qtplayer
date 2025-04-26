#ifndef MAINWIDGET_H
#define MAINWIDGET_H

#include <QWidget>
#include <QLabel>
#include <QPixmap>
#include <QPushButton>
#include <QDebug>
#include <QThread>
#include "decodevideo.h"

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
    QImage image;
    QLabel * lab;
public slots:
    void btnClickFuction();
    void receiveImage(QImage img);
protected:
    void paintEvent(QPaintEvent *event);

};

#endif // MAINWIDGET_H
