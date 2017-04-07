package td.utils;

import android.media.MediaPlayer;
import android.net.Uri;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import com.motu.sdk.ChannelUtils;
public class VideoUtils {

	static MediaView videoView=null;
	
	public static void setFilePath(String fileName,String type)
	{

		System.out.println("setFilePath "+fileName);
	}
	
	public static void stopVideo()
	{

		 
		ChannelUtils.actionActivity.runOnUiThread(new Runnable() {
			
			@Override
			public void run() { 
				if(videoView!=null){
					((ViewGroup) videoView.getParent()).removeView(videoView);  
					videoView=null;
				}
				
			}
		});
	}
	
	public static void _nativePlaySkin(){
		ChannelUtils.actionActivity.runOnUiThread(new Runnable() { 
			@Override
			public void run() {  
				if(ChannelUtils.getActivity().hasEnterGame){ 
					nativePlaySkin();
				}
			}
		});
	}
	
	
	public static void _nativePlayFinish(){
		ChannelUtils.actionActivity.runOnUiThread(new Runnable() { 
			@Override
			public void run() {  
				if(ChannelUtils.getActivity().hasEnterGame){ 
					nativePlayFinish();
				}
			}
		});
	}
	
	
	public static void playVideo()
	{


		ChannelUtils.actionActivity.runOnUiThread(new Runnable() {
			
			@Override
			public void run() { 
				/*
				if(videoView==null){
				    videoView =  new MediaView(ChannelUtils.actionActivity);
					Uri uri = Uri.parse("android.resource://" + ChannelUtils.actionActivity.getPackageName() + "/"+ R.raw.dgrmov); //do not add any extension
					videoView.setVideoURI(uri);
					videoView.start();
					videoView.requestFocus();
					((FrameLayout) ChannelUtils.actionActivity.findViewById(R.id.mediaGameView)).addView(videoView);  
					
					videoView.setOnCompletionListener(new android.media.MediaPlayer.OnCompletionListener(){
				              @Override  
				             public void onCompletion(MediaPlayer arg0) {  
				            	  stopVideo();
				            	  _nativePlayFinish();
				            	  System.out.println("nativePlayFinish"); 
				              }  
				    });    
					
					videoView.setOnTouchListener(new View.OnTouchListener() {
						
						@Override
						public boolean onTouch(View arg0, MotionEvent arg1) {
							  	stopVideo();
							  	_nativePlaySkin();
							 	System.out.println("nativePlaySkin"); 
							 	return false;
						}
					});
				}*/
				
			}
		});
		
	}
	
	
	
	public static String getIsPlayVideo() {
		if(videoView==null){
			return "0";
		}else{ 
			return "1";
		} 
	}


	
	public static native void nativePlayFinish();
	public static native void nativePlaySkin();
	
}
