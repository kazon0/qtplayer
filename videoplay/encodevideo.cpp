#include "encodevideo.h"

encodeVideo::encodeVideo():QThread ()
{
    //1.注册组件
    av_register_all();

    //类成员变量的赋值
    this->formatContext = avformat_alloc_context();
    this->packet = av_packet_alloc();
    this->pktIndex = 0;
    this->flag = true;

}
//准备工作 通过最终输出的文件重复执行
void encodeVideo::initEncode()
{
    //2.通过文件后缀得到最佳输出格式
    AVOutputFormat * outputFormat = av_guess_format(nullptr,"../fileout/Warcraft3_End.h264",nullptr);
    if(outputFormat == nullptr){
        qDebug()<<"av_guess_format fail";
    }else {
        qDebug()<<"av_guess_format success";
    }

    //2.1 设置文件格式
    this->formatContext->oformat = outputFormat;
    //3.打开视频流
    int res = avio_open(&(this->formatContext->pb),"../fileout/Warcraft3_End.h264",AVIO_FLAG_WRITE);

    if(res<0){
        qDebug()<<"avio_open fail";
    }else {
        qDebug()<<"avio_open success";
    }
    //3.1 新建视频流
    AVStream * newStream = avformat_new_stream(this->formatContext,nullptr);
    if(newStream == nullptr){
        qDebug()<<"avformat_new_stream fail";
    }else {
        qDebug()<<"avformat_new_stream success";
    }

    //3.2 编码器的上下文环境初始化
    this->codecContext = newStream->codec;
    //3.3 设置视频基本信息
    this->codecContext->width = 800;    //编码视频文件宽度
    this->codecContext->height = 368;   //编码视频文件高度
    this->codecContext->bit_rate = 579*1000;    //编码视频文件码率
    this->codecContext->framerate = {24,1};     //编码视频文件帧率  1秒24帧
    this->codecContext->time_base = {1,24};     //编码视频文件时间基
    //3.4 设置视频高级设置信息
    this->codecContext->gop_size = 10;  //I/P/B 以10帧为一组
    this->codecContext->qmax = 51;      //清晰度
    this->codecContext->qmin = 10;      //清晰度
    this->codecContext->max_b_frames = 0;   //B帧压缩为0
    this->codecContext->pix_fmt = AV_PIX_FMT_YUV420P;   //YUV格式
    this->codecContext->codec_type = AVMEDIA_TYPE_VIDEO;    //编码类型
    this->codecContext->codec_id = outputFormat->video_codec;   //设置编码ID

    //4.查找解码器
    AVCodec * encodec = avcodec_find_encoder(this->codecContext->codec_id);
    res=avcodec_open2(this->codecContext,encodec,nullptr);
    if(res!=0){
        qDebug()<<"avcodec_open2 fail";
    }else {
        qDebug()<<"avcodec_open2 success";
    }

    //5.写头帧数据
    res=avformat_write_header(this->formatContext,nullptr);
    if(res<0){
        qDebug()<<"avformat_write_header fail";
    }else {
        qDebug()<<"avformat_write_header success";
    }




}
//写尾帧
void encodeVideo::writeTrailer()
{
    //写尾帧信息
    av_write_trailer(this->formatContext);
    //关闭视频流
    avio_close(this->formatContext->pb);
    //释放视频文件上下文环境对象
    avformat_free_context(this->formatContext);
}

void encodeVideo::run()
{
    this->flag=true;
    while (1) {
        if(this->flag==false){
            break;
        }
        if(YUVQueue.size() == 0){
            continue;
        }
        qDebug()<<"YUVQueue.size() = "<<YUVQueue.size();
        //从队列中取出    AVFrame
        AVFrame * currentYuv = YUVQueue.dequeue();

        //6.将AVFrame数据交给编码器
        int res=avcodec_send_frame(this->codecContext,currentYuv);
        if(res!=0){
            qDebug()<<"avcodec_send_frame fail";

        }else {
            qDebug()<<"avcodec_send_frame success";
        }
        while (res >= 0) {
            currentYuv->pts = this->pktIndex++;
            qDebug()<<"this->pkIndex = "<<this->pktIndex;
            //7.将像素数据转成压缩数据（码流数据）
            res=avcodec_receive_packet(this->codecContext,this->packet);
            if(res != 0){
                qDebug()<<"avcodec_receive_packet fail";
                break;
            }else {
                qDebug()<<"avcodec_receive_packet success";
            }
            //8.写一帧压缩数据到文件formatContext
            res = av_interleaved_write_frame(this->formatContext,this->packet);
            if(res != 0){
                qDebug()<<"av_interleaved_write_frame fail";
                break;
            }else {
                qDebug()<<"av_interleaved_write_frame success";
            }
        }
        av_packet_unref(this->packet);
    }
}

void encodeVideo::reciverYUV(AVFrame *yuv)
{
    YUVQueue.enqueue(yuv);
}

void encodeVideo::closeFile()
{
    qDebug()<<"解码通知结束：writeTrailer";
    writeTrailer();
    this->flag = false;
}
