package com.motu.luan2;

import java.util.Timer;
import java.util.TimerTask;

import td.utils.MediaView;

import com.motu.sdk.ChannelAndroid;
import com.motu.sdk.ChannelUtils;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.MediaPlayer;
import android.net.Uri;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.View;
public class LogoLayer {

	private MediaView videoView = null;
	private final Timer mTimer = new Timer();
	private int iddgrlogomv = 0;
	/** 
	    * 监听是否点击了home键将客户端推到后台 
	    */  
	   private BroadcastReceiver mHomeKeyEventReceiver = null;
	   public class MyReceiver extends  BroadcastReceiver{  
	       String SYSTEM_REASON = "reason";  
	       String SYSTEM_HOME_KEY = "homekey";  
	       String SYSTEM_HOME_KEY_LONG = "recentapps";  
	          
	       @Override  
	       public void onReceive(Context context, Intent intent) {  
	           String action = intent.getAction();  
	           if (action.equals(Intent.ACTION_CLOSE_SYSTEM_DIALOGS)) {  
	               String reason = intent.getStringExtra(SYSTEM_REASON);  
	               if (TextUtils.equals(reason, SYSTEM_HOME_KEY)) {  
	                    //表示按了home键,程序到了后台  
	            	   skinVideo();
	               } 
	           }   
	       }  
	   }
	   
	   private Boolean filterChannels(){
		   if(ChannelAndroid.CHANNEL_ANDROID_TENCENT == ChannelAndroid.getCurrentPlatform() || ChannelAndroid.CHANNEL_ANDROID_BAIDU == ChannelAndroid.getCurrentPlatform()){
			   return true;
		   }
		   return false;
	   }
	   
	public void startLogo() {
		int idvideowiew = AppActivity.getContext().getResources().getIdentifier("videowiew", "id", AppActivity.getContext().getPackageName());
		videoView = (MediaView)((Activity) AppActivity.getContext()).findViewById(idvideowiew);   //videoView =  new VideoView(this);
		iddgrlogomv = AppActivity.getContext().getResources().getIdentifier("dgrlogomv", "raw", AppActivity.getContext().getPackageName());
		if (0 != iddgrlogomv) {
			videoView.setZOrderOnTop(true);	
		}
			
		if(filterChannels()){
			if(ChannelAndroid.CHANNEL_ANDROID_BAIDU == ChannelAndroid.getCurrentPlatform()){
				ChannelAndroid.sharePlatform().init("");
			}
			videoView.setVisibility(View.INVISIBLE);
			int delayTime = 2000; 
			mTimer.schedule(new TimerTask() {					  
	            @Override  
	            public void run() {
	            	ChannelUtils.actionActivity.runOnUiThread(new Runnable() {
	        			
	        			@Override
	        			public void run() {
	        				ChannelUtils.actionActivity.loadingDefault.setVisibility(View.INVISIBLE);
	        				playVideo();
	        			}
	        		});
	            	}   
	        	}, delayTime);
		}else {
			playVideo();
		}
		
	}

	
	public void playVideo() {
		
		if (0==iddgrlogomv) {
			skinVideo();			
		}else {
			videoView.setVisibility(View.VISIBLE);
			Uri uri = Uri.parse("android.resource://" + AppActivity.getContext().getPackageName() + "/"+ iddgrlogomv); //do not add any extension
			videoView.setVideoURI(uri);
			videoView.getHolder().setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
			videoView.requestFocus();
		    videoView.start();
			videoView.setOnCompletionListener(new android.media.MediaPlayer.OnCompletionListener(){
		              @Override  
		             public void onCompletion(MediaPlayer arg0) {  
		            	  skinVideo();
		              }  
		    });
			
			videoView.setOnErrorListener(new android.media.MediaPlayer.OnErrorListener() {
				
				@Override
				public boolean onError(MediaPlayer mp, int what, int extra) {
					// TODO Auto-generated method stub
					skinVideo();
					return false;
				}
			});
			
			
			//touch screen skin video
			videoView.setOnTouchListener(new View.OnTouchListener() {
				@Override
				public boolean onTouch(View v, MotionEvent event) {
					// TODO Auto-generated method stub
					skinVideo();
					return false;
				}
			});
			mHomeKeyEventReceiver = new MyReceiver();
			AppActivity.getContext().registerReceiver(mHomeKeyEventReceiver, new IntentFilter(Intent.ACTION_CLOSE_SYSTEM_DIALOGS)); 
		}
	}
	
	public void skinVideo()	{
		if (mHomeKeyEventReceiver != null) {
			AppActivity.getContext().unregisterReceiver(mHomeKeyEventReceiver);
		}
		videoView.setVisibility(View.GONE);
		if(filterChannels()){
			ChannelUtils.actionActivity.enterCheckSo();
			return;
		}
		int delayTime = 2000; 
		mTimer.schedule(new TimerTask() {					  
            @Override  
            public void run() {
            	ChannelUtils.actionActivity.enterCheckSo();
            	}   
        	}, delayTime);
	}
	
}
