--------------
####Code:

10001:内部错误

10002:参数错误


####设备相关：

//# 发送操作指令事件
let SEND_LAUNCH_CMD = "SEND_LAUNCH_CMD"

//# 发送监控数据事件
let SEND_MON_DATA = "SEND_MON_DATA"

//# 开启监控数据传输
let IS_SEND_MON_DATA = "IS_SEND_MON_DATA"

//#发送视频数据
let SEND_VIDEO_DATA = "SEND_VIDEO_DATA"


-----------
=======
SEND\_VIDEO_DATA
============
发送视频数据

<pre>
{
	code:11111/10001
	msg:'错误信息'
	data:'image byte图像数据'

}
</pre>

-----------

-----------
=======
SEND\_MON_DATA
============
发送监控数据

<pre>
{
	code:11111/10001
	msg:'错误信息'
	data:{
		'temp_out':室外温度,
		'temp_soil':室内温度,
		'hum_out':室外湿度,
		'hum_soil':土壤湿度,
		'mac_angle':电机角度
	}

}
</pre>

-----------


===================
URL: switch_video
===========
切换开启传输视频数据
####method:GET

####param: {"data":Bool}

-----------

===================
URL: switch_mon
===========
切换开启监控数据

####method:GET

####param: {"data":Bool}