#include "mainwidget.h"

MainWidget::MainWidget(QWidget *parent)
 :QWidget (parent)
{
    this->decodeThread = new DecodeVideo();
      // 确保连接成功
      bool connected = connect(this->decodeThread, SIGNAL(sendImage(QImage)),
                               this, SLOT(receiveImage(QImage)));
      qDebug() << "信号槽连接状态：" << connected;  // 应该输出 true
    initUI();
}

MainWidget::~MainWidget()
{

}

void MainWidget::initUI(){
    this->resize(1500,800);
    this->lab = new QLabel("xxxx",this);
    this->lab->setGeometry(0,0,1500,750);
    this->btn = new QPushButton("开始播放",this);
    this->btn->setGeometry(0,760,100,30);

    connect(btn,SIGNAL(clicked()),this,SLOT(btnClickFuction()));
}

void MainWidget::btnClickFuction()
{
    this->decodeThread->start();
}

void MainWidget::paintEvent(QPaintEvent *event)
{

    if(!this->image.isNull()){
        //根据lab宽高来设置image宽高 （等比例压缩或放大）
        // 修改这里：将缩放后的图像赋值回去
             QImage scaledImg = this->image.scaled(this->lab->width(),
                                                  this->lab->height(),
                                                  Qt::KeepAspectRatio);
             this->lab->setPixmap(QPixmap::fromImage(scaledImg));
             qDebug() << "接收到图像，尺寸：" << scaledImg.size();  // 打印图像尺寸
    }
}

void MainWidget::receiveImage(QImage img)
{
    this->image = img;
    //窗口刷新 自动触发painevent
    update();

}
