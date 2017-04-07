package com.motu.luan2.notification;

import java.util.Timer;

import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

import com.motu.luan2.*;
//import com.motu.luan2.GlobalData;

public class NotificationService extends Service {
	String mmessage = "" ;
    int nId = 0;
    boolean bAddNumber = false;
	long lNTime = 0;
	@Override
	public IBinder onBind(Intent arg0) {
		//TODO Auto-generated method stub
		return null;
	}

	public NotificationService(){
		System.out.println("CCNotifitionService.CCNotifitionService()");
	}

	@Override
	public void onCreate()
	{
		//System.out.println("onCreate()"+mMessageList.size());
		Log.v("cocos2d-x debug info", "开启推送服务service");
		super.onCreate();
		
		GlobalData sharedData = (GlobalData)getApplication();
		sharedData.getNotificationList(this);
		
		Timer timer = new Timer(true);
		timer.schedule(new java.util.TimerTask() 
		{ 
			public void run() {
				if(checkPushStatue())
				{
					showNotification();
				}
			} 
		}, 0, 1*1000); 
	}

	@Override	
	public void onStart(Intent intent, int startId)
	{
		/*if((intent!=null) )
		{
			NotificationMessage message = (NotificationMessage)intent.getSerializableExtra(iGame.SER_KEY); 
			if(message!=null) {
			}
		}*/
	}

	@Override
	public void onDestroy() {

		super.onDestroy();
	}

	/*public NotificationService(Context context){

	}*/
	
	public boolean checkPushStatue(){
		GlobalData shareData = (GlobalData)getApplication();
		//Log.v("cocos2d-x debug info", "检测推送状态:"+shareData.mMessageList.size());
		long currentTime = System.currentTimeMillis();
	
		if(shareData.mMessageList.size()>0)
		{
			//int listSize = mMessageList.size();
            int i = 0;
			for(NotificationMessage nmes:shareData.mMessageList) {
				//System.out.println("通知:"+nmes.getMark()+","+currentTime);
				if(nmes.getTime() <= currentTime)
				{
					mmessage = nmes.getMessage();
					lNTime = nmes.getTime();
					nId = nmes.getId();
					bAddNumber = nmes.getAddNumber();
					if(nmes.getSpace() > 0) {
						mmessage = nmes.getMessage(nmes.getMsgIdx());
					}
				    int msgIdx = nmes.getMsgIdx();
				    int msgNum = nmes.getMsgNum();
				    
					//创建第二天的本地通知
				    if(nmes.getIsOnce() == false) {
				    	NotificationMessage nmNext = new NotificationMessage();
						long nexttime = lNTime+24*60*60*1000;
						if(nmes.getSpace() > 0) {
							nexttime = lNTime+nmes.getSpace()*1000;
							
							if(msgIdx >= msgNum-1) msgIdx = 0;
							else msgIdx++;
							
							nmNext.setMessage(nmes.msgContent, nmes.getMsgNum());
							nmNext.setMsgIdx(msgIdx);
						}
						else {
							nmNext.setMessage(mmessage);
						}
						
						nmNext.setTime(nexttime);
						nmNext.setId(nId);
						nmNext.setAddNumber(bAddNumber);
						nmNext.setIsOnce(false);
						
						shareData.mMessageList.remove(i);
						shareData.mMessageList.add(nmNext);
				    }else {
				    	shareData.mMessageList.remove(i);
				    }
		
					return true;
				}
				i++;
			}
		}
		else {
			return false;
		}
		return false;
	}

	public boolean isRunningForeground() {
		ActivityManager am = (ActivityManager)getSystemService(Context.ACTIVITY_SERVICE);
		ComponentName cn = am.getRunningTasks(1).get(0).topActivity;
		String currentPackageName = cn.getPackageName();
		if (currentPackageName != null && currentPackageName.equals(getPackageName())) {
			return true;
		}
		return false;
	}
	public void showNotification()
	{
		if(isRunningForeground()) {
			//Log.v("cocos2d-x debug info", "app在前台运行不显示通知");
			return; 
		}
	
		int app_name_id = getResources().getIdentifier("app_name", "string",getPackageName());
		CharSequence appName = getString(app_name_id);
		int appIconIdentify = getResources().getIdentifier("push_icon", "drawable",getPackageName());
		
		//Log.v("cocos2d-x debug info", "应用程序图标:"+appIconIdentify);
		//Log.v("cocos2d-x debug info", "应用程序名:"+appName);
		
		//@SuppressWarnings("deprecation")
		//Notification notification = new Notification(appIconIdentify, mmessage, System.currentTimeMillis());
		//notification.defaults = Notification.DEFAULT_SOUND;
		
		Context context = getApplicationContext(); 
		
		Intent it = new Intent(context, AppActivity.class);
		//it.addCategory(Intent.CATEGORY_LAUNCHER);
		it.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK |Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED);
 
		PendingIntent pintent = PendingIntent.getActivity(this, 1001,it,PendingIntent.FLAG_UPDATE_CURRENT);
		//notification.setLatestEventInfo(context,appName,mmessage,pintent);
		Notification notification = new Notification.Builder(context)    
        .setAutoCancel(true)    
        .setContentTitle(appName)    
        .setContentText(mmessage)    
        .setContentIntent(pintent)    
        .setSmallIcon(appIconIdentify)    
        .setWhen(System.currentTimeMillis())    
        .build();   
		//String service = Context.NOTIFICATION_SERVICE;
		NotificationManager mNotificationManager =(NotificationManager)context.getSystemService( Context.NOTIFICATION_SERVICE);
		 
		if(bAddNumber) notification.number++;
		mNotificationManager.notify(nId, notification);
		//startForeground(1001,notification);
	}
}
