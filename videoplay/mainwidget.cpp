#include "mainwidget.h"

MainWidget::MainWidget(QWidget *parent)
    : QWidget(parent)
{
    this->decodeThread = new DecodeVideo();
    this->encodeThread = new encodeVideo();

    connect(decodeThread, SIGNAL(sendImage(QImage)), this, SLOT(recieveImage(QImage)));

    this->initUI();
    this->encodeThread->initEncode();

    connect(this->decodeThread,SIGNAL(sendYUV(AVFrame *)),this->encodeThread,SLOT(reciverYUV(AVFrame *)));
    connect(this->decodeThread,SIGNAL(sendClose()),this->encodeThread,SLOT(closeFile()));



}

MainWidget::~MainWidget()
{

}

void MainWidget::initUI()
{
    this->resize(1500,800);
    this->lab = new QLabel(this);
    this->lab->setGeometry(10,10,1500,750);

    this->btn = new QPushButton("button",this);
    this->btn->setGeometry(10,760,150,30);


    connect(btn,SIGNAL(clicked()),this,SLOT(btnClickFunction()));
}

void MainWidget::btnClickFunction()
{
    this->decodeThread->start();
    this->encodeThread->start();
}

void MainWidget::paintEvent(QPaintEvent *event)
{
    if(!this->image.isNull()){
        //根据label的尺寸设置image宽高（等比例缩放）
        this->image.scaled(this->lab->width(),this->lab->height());
        //给label设置图片
        this->lab->setPixmap(QPixmap::fromImage(this->image));
    }
}

//从解码线程接收解码出来的图像
void MainWidget::recieveImage(QImage img)
{
    this->image = img;
    //窗口刷新  自动触发paintEvent重绘事件
    update();

}
