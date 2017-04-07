package com.motu.luan2;

import java.util.ArrayList;
import java.util.List;
//import android.app.Application; 

import android.app.NotificationManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.util.Log;

import com.motu.luan2.notification.NotificationMessage;
//import com.motu.sdk.AppBaseData;

public class GlobalData extends AppBaseData{
	//本地通知队列
	public List<NotificationMessage> mMessageList = new ArrayList<NotificationMessage>(); 
	//保存、读取存储在本地的通知列表
	public void saveNotificationList(Context ctx) {
		SharedPreferences sp = ctx.getSharedPreferences("BGNotification", MODE_PRIVATE);
		if(sp == null) return;
		Editor editor = sp.edit();//获取编辑器
		int num = mMessageList.size();
		//Log.v("cocos2d-x debug info", "保存本地通知列表:"+num);
		int i = 0;
		editor.putInt("NUM", num);
		String key;
		for(NotificationMessage nmes:mMessageList) {
			key = "ID_"+i;
			editor.putInt(key, nmes.getId());
			key = "TIME_"+i;
			editor.putLong(key,nmes.getTime());
			key = "SHOW_NUMBER_"+i;
			editor.putBoolean(key,nmes.getAddNumber());
			key = "SPACE_"+i;
			editor.putInt(key, nmes.getSpace());
			key = "ONCE_"+i;
			editor.putBoolean(key,nmes.getIsOnce());
			if(nmes.getSpace() > 0) {
				int msgnum = nmes.getMsgNum();
				int msgidx = nmes.getMsgIdx();
				
				key = "MESSAGE_NUM_"+i;
				editor.putInt(key, msgnum);
				
				key = "MESSAGE_IDX_"+i;
				editor.putInt(key, msgidx);
				
				for(int idx = 0;idx < msgnum;idx++) {
					key = "MESSAGE_"+i+"_"+idx;
					editor.putString(key,nmes.getMessage(idx));
				}
			}else {
				key = "MESSAGE_"+i;
				editor.putString(key,nmes.getMessage());
			}
			i++;
		}
		editor.commit();
	}
	public void getNotificationList(Context ctx) {
		SharedPreferences sp = ctx.getSharedPreferences("BGNotification", MODE_PRIVATE);
		if(sp == null) return;
		int num = sp.getInt("NUM",0);
		//Log.v("cocos2d-x debug info", "读取本地通知列表:"+num);
		if(num > 0) {
			mMessageList.clear();
			for(int i = 0;i < num;i++) {
			    String key = "ID_"+i;
				int nId = sp.getInt(key,0);
				key = "MESSAGE_"+i;
				String message = sp.getString(key,"");
				key = "TIME_"+i;
				long time = sp.getLong(key,0);
				key = "SHOW_NUMBER_"+i;
				boolean showNumber = sp.getBoolean(key,false);
				key = "SPACE_"+i;
				int space = sp.getInt(key,0);
				key = "ONCE_"+i;
				boolean bOnce = sp.getBoolean(key,false);
				
				int spacetime = 24*60*60*1000;
				if(space > 0) spacetime = space;
				//Log.v("cocos2d-x debug info", "本地通知列表描述:"+message);
				//纠正时间，避免过期
				long currentTime = System.currentTimeMillis();
				if(currentTime > time) {
					int order = 0;
					while(currentTime > time ) {
						time = time + spacetime;
						order++;
						if(order > 1000) break;
					}
				}
				
				NotificationMessage nmNext = new NotificationMessage();
				nmNext.setTime(time);
				nmNext.setId(nId);
				nmNext.setAddNumber(showNumber);
				nmNext.setSpace(space);
				nmNext.setIsOnce(bOnce);
				if(space > 0) {
					key = "MESSAGE_NUM_"+i;
					int msgnum = sp.getInt(key,0);
					key = "MESSAGE_IDX_"+i;
					int msgidx = sp.getInt(key,0);
					String msgContent[]= new String[msgnum];
					for(int idx = 0;idx < msgnum;idx++) {
						key = "MESSAGE_"+i+"_"+idx;
						msgContent[idx] = sp.getString(key,"");
					}
					nmNext.setMessage(msgContent,msgnum);
					nmNext.setMsgIdx(msgidx);
				}else {
					nmNext.setMessage(message);
				}
				mMessageList.add(nmNext);
				
			}
		}
	}
	//清楚通知标志
	void clearNotificationMark(Context ctx) {
		String service = Context.NOTIFICATION_SERVICE;
		NotificationManager mNotificationManager =(NotificationManager)ctx.getSystemService(service);
		mNotificationManager.cancelAll();
	}
}


