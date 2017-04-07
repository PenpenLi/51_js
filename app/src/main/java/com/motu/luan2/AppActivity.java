/****************************************************************************

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/

package com.motu.luan2;
import java.util.ArrayList;
import java.util.Timer;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHelper;

import td.utils.CheckSoThread;
import td.utils.Conf;
import td.utils.Constants;
import android.annotation.TargetApi;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.DialogInterface.OnClickListener;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.graphics.Point;
import android.graphics.drawable.AnimationDrawable;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.LinearInterpolator;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import cn.sharesdk.ShareSDKUtils;
import com.motu.luan2.LogoLayer;
import com.motu.luan2.DownloadActivity;
import com.motu.luan2.DynamicResource;
import com.motu.luan2.notification.*;
import com.motu.sdk.ChannelAndroid;
import com.motu.luan2.ChannelBase;
import com.motu.sdk.ChannelUtils;

public class AppActivity extends Cocos2dxActivity{

	private static AppActivity appObj = null;
	private CheckSoThread checkThread;
	static String hostIPAdress = "0.0.0.0";
	public final static int  convert = 1000;
	public Boolean hasEnterGame=false;
	private static boolean isDownload = false;
	private static String strDownloadUrl = "";
	private LogoLayer logolayerOBj = null;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		//涓���㈢��涓や釜璋���ㄩ『搴�涓���介�� 
		com.youme.im.IMEngine.init(this);
		super.onCreate(savedInstanceState);
		appObj = this;
		new DynamicResource().init(this);
		setContentView(DynamicResource.update_so_layout); 
		ChannelUtils.actionActivity=this;  
		
		loadingTxt = (TextView) findViewById(DynamicResource.loading_txt_id);
		loadingBg=(ImageView) findViewById(DynamicResource.loadingBg_id);
		loadingIcon = (ImageView) findViewById(DynamicResource.loadingIcon_id);
		loadingDefault = (ImageView) findViewById(DynamicResource.loadingView_id);
		loadingTxt.setText("");
		ChannelUtils.actionActivity = this;  
		Constants.context=this;
        ChannelAndroid.sharePlatform().activityCreate(savedInstanceState);
		super.onCreate(savedInstanceState);
		
        DisplayMetrics dm = new DisplayMetrics();
		 ChannelUtils.getActivity().getWindowManager().getDefaultDisplay().getMetrics(dm); 
		 int  sH = dm.heightPixels; 
		 float density=dm.density;
		 
		 RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams)loadingIcon.getLayoutParams();
		 params.bottomMargin=sH*8/20;
		 loadingIcon.setLayoutParams(params);
		 loadingIcon.setScaleX(PlatformInfo.getScaleSize());
		 loadingIcon.setScaleY(PlatformInfo.getScaleSize());

		 params = (RelativeLayout.LayoutParams)loadingBg.getLayoutParams();
		 params.bottomMargin=sH*8/20;
		 loadingBg.setLayoutParams(params);
		 
		 params = (RelativeLayout.LayoutParams)loadingTxt.getLayoutParams();
		 params.bottomMargin=(sH*7)/20;
		 loadingTxt.setLayoutParams(params);
		 
		 Animation operatingAnim = AnimationUtils.loadAnimation(this, DynamicResource.loading_bg_anim);  
		 LinearInterpolator lin = new LinearInterpolator();  
		 operatingAnim.setInterpolator(lin);
		 loadingBg.setScaleX(PlatformInfo.getScaleSize());
		 loadingBg.setScaleY(PlatformInfo.getScaleSize());
		 loadingBg.startAnimation(operatingAnim);  
		
		 operatingAnim = AnimationUtils.loadAnimation(this, DynamicResource.loading_icon_anim);  
		  lin = new LinearInterpolator();  
		 operatingAnim.setInterpolator(lin);  
		 loadingIcon.startAnimation(operatingAnim);  
		 
		 logolayerOBj = new LogoLayer();
		 logolayerOBj.startLogo();
		 
		setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
		hostIPAdress = getHostIpAddress();
		ShareSDKUtils.prepare();
		
		
		startService(new Intent(AppActivity.this, NotificationService.class));
	}
	public static AppActivity getActivity() {
		return appObj;
	}
	public boolean isNetworkAvailable() {
		ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = cm.getActiveNetworkInfo();
		if (info != null && info.getState() == NetworkInfo.State.CONNECTED)
			return true;
		return false;
	    } 
	 
	public String getHostIpAddress() {
		WifiManager wifiMgr = (WifiManager) getSystemService(WIFI_SERVICE);
		WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
		int ip = wifiInfo.getIpAddress();
		return ((ip & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF));
	}
	
	public static String getLocalIpAddress() {
		return hostIPAdress;
	}
	public void showTips(){

		AlertDialog.Builder builder = new Builder(this);
		builder.setMessage(DynamicResource.leaveMsg);
		builder.setTitle(DynamicResource.app_name);

		builder.setPositiveButton(DynamicResource.confirm, new OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				ChannelAndroid.sharePlatform().platformExit();
				dialog.dismiss();
				if(ChannelAndroid.currPlatform != ChannelAndroid.CHANNEL_ANDROID_QUICK){
					Cocos2dxHelper.terminateProcess();
				}
			}
		});

		builder.setNegativeButton(DynamicResource.cancel, new OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		});

		builder.create().show();
	}
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		super.onKeyDown(keyCode, event);
		// TODO Auto-generated method stub
		if(keyCode == KeyEvent.KEYCODE_BACK) {
			ChannelAndroid.sharePlatform().keybackActivity();
			//showTips();
		}
		return super.onKeyDown(keyCode, event);
	}
    @Override
    protected void onNewIntent(Intent intent) {       
        super.onNewIntent(intent);
        ChannelAndroid.sharePlatform().onNewIntent(intent);
    }
    
    @Override
	protected void onRestart() {
		// TODO Auto-generated method stub
		super.onStart();
		ChannelAndroid.sharePlatform().activityOnReStart();
	}
	@Override
	protected void onStart() {
		// TODO Auto-generated method stub
	    if(ChannelAndroid.currPlatform == ChannelAndroid.CHANNEL_ANDROID_IDN){
			ChannelAndroid.sharePlatform().activityOnStart();
			super.onStart();
		}else{
			super.onStart();
			ChannelAndroid.sharePlatform().activityOnStart();
		}
	}
	
	@Override
	protected void onPause() {  
	    if(ChannelAndroid.currPlatform == ChannelAndroid.CHANNEL_ANDROID_IDN){
	        PlatformInfo.PlatformInstance().onPause();
	        //TalkingDataGA.onPause(this);
	        ChannelAndroid.sharePlatform().activityPause();
	        super.onPause();  
		}else{
	        super.onPause();  
	        PlatformInfo.PlatformInstance().onPause();
	        //TalkingDataGA.onPause(this);
	        ChannelAndroid.sharePlatform().activityPause();
		}
    }  
	protected void onResume() {  
	    if(ChannelAndroid.currPlatform == ChannelAndroid.CHANNEL_ANDROID_IDN){
	        PlatformInfo.PlatformInstance().onResume();
	        //TalkingDataGA.onResume(this);
	        ChannelAndroid.sharePlatform().activityResume();
	        super.onResume();  
		}else{
	        super.onResume();  
	        PlatformInfo.PlatformInstance().onResume();
	        //TalkingDataGA.onResume(this);
	        ChannelAndroid.sharePlatform().activityResume();
		}
    }
	@Override
	protected void onDestroy() {  
	    if(ChannelAndroid.currPlatform == ChannelAndroid.CHANNEL_ANDROID_IDN){
	        PlatformInfo.PlatformInstance().onDestroy();
	        ChannelAndroid.sharePlatform().activityDestory();
	        super.onDestroy();  
		}else{
	        super.onDestroy();  
	        PlatformInfo.PlatformInstance().onDestroy();
	        ChannelAndroid.sharePlatform().activityDestory();
		}
    }

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
        ChannelAndroid.sharePlatform().activityConfigurationChanged(newConfig);
	}
	
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(ChannelAndroid.currPlatform == ChannelAndroid.CHANNEL_ANDROID_MEAST){
			if(!ChannelAndroid.sharePlatform().activityResult(requestCode, resultCode, data)){
	    		super.onActivityResult(requestCode, resultCode, data);
			}
		}else if(ChannelAndroid.currPlatform == ChannelAndroid.CHANNEL_ANDROID_IDN){
    		ChannelAndroid.sharePlatform().activityResult(requestCode, resultCode, data);
    		super.onActivityResult(requestCode, resultCode, data);
		}else{
    		super.onActivityResult(requestCode, resultCode, data);
    		ChannelAndroid.sharePlatform().activityResult(requestCode, resultCode, data);
		}
    }
    
	@Override
	public void onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState);
		ChannelAndroid.sharePlatform().saveInstanceState(outState);
	}
	//Android-M ��插��娆�������瑕�
	@TargetApi(23)
	public void onRequestPermissionsResult(int requestCode,  String[] permissions, int[] grantResults) {
		ChannelAndroid.sharePlatform().onRequestPermissionsResult(requestCode,permissions,grantResults);
	}

	private final Timer mTimer = new Timer();
	private ImageView loadingBg;
	private TextView loadingTxt;
	private ImageView loadingIcon; 
	public ImageView loadingDefault; 
	private AnimationDrawable animationDrawable = null;
	private int progress;
	
	public static void update(String sUrl)
	{
		Intent intent = new Intent(ChannelUtils.actionActivity, DownloadActivity.class);
		ChannelUtils.actionActivity.startActivity(intent);
		strDownloadUrl = sUrl;
		setDownload(true);
		

	}
	public static boolean isDownload() {
		return isDownload;
	}

	public static void setDownload(boolean isDownload) {
		appObj.isDownload = isDownload;
	}
	
	public static String getDownloadUrl(){
		return strDownloadUrl;
	}
	public void setNeedUpdate(final String downPath,final Boolean isGameUpdate){
	this.runOnUiThread(new Runnable() {
			
			@Override
			public void run() { 
				 loadingTxt.setText(DynamicResource.lowVersion); 
				if(isGameUpdate){					
						update(downPath); 
				}else{
					appObj.openURL(downPath);
				}				 
			}
		});
	}
	public static void openURL(String url) 
	{ 
		try {
			Intent i = new Intent(Intent.ACTION_VIEW);  
			i.setData(Uri.parse(url));
			ChannelUtils.actionActivity.startActivity(i);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			Log.e("openURL", "Exception", e);  
		}
	}
	public void enterCheckSo(){
		ChannelUtils.actionActivity.runOnUiThread(new Runnable() {
			
			@Override
			public void run() { 
				   if(loadingDefault!=null){ 
	    				((ViewGroup) loadingDefault.getParent()).removeView(loadingDefault);
	    				loadingDefault=null;
				   }
					Conf.sharedConf().loadConf();
					/*if(!Conf.sharedConf().getBool("g_sys_isCloseCG")){ 
						VideoUtils.playVideo(); 
					}*/
					
					if (checkThread == null) {
						checkThread = new CheckSoThread();
						checkThread.running = true;
						checkThread.start();
					}  				
	             
			}
		});
	}
	
	/** 杩���ユ父��� */
	public void enterGame() {
		this.runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				if (loadingBg != null) {
					loadingBg.clearAnimation(); 
					((ViewGroup) loadingBg.getParent()).removeView(loadingBg);
					loadingBg=null;
				}
				if (loadingIcon != null) {
					loadingIcon.clearAnimation(); 
					((ViewGroup) loadingIcon.getParent()).removeView(loadingIcon);
					loadingIcon=null;
				}
				if (loadingTxt != null) {
					((ViewGroup) loadingTxt.getParent()).removeView(loadingTxt);
				}
				if(loadingDefault != null){
					((ViewGroup) loadingDefault.getParent()).removeView(loadingDefault);
					loadingDefault=null;
				}

				hasEnterGame=true;
				//娣诲��searchPath
				ChannelBase.addObbSearchPath();
				ChannelAndroid.setChannelPraram();
				FrameLayout layout= (FrameLayout) findViewById(DynamicResource.frameGameLayout_id);
				initFrame(layout);
				System.out.println("entergame"); 
				 
			}
		});

	}
	
	public void setThreadStatus(){ 
		this.runOnUiThread(new Runnable() {
			
			@Override
			public void run() { 
				
				if(checkThread!=null){
					 switch(checkThread.status){
					 	case CheckSoThread.STATUS_CHECK_VERSION: 
					 		if(checkThread.tryWebCount==0){ 
								loadingTxt.setText(DynamicResource.checking);
					 		}else{

								loadingTxt.setText(DynamicResource.checking +"("+checkThread.tryWebCount+")");
					 		}
							break; 
					 	case CheckSoThread.STATUS_PACK_SO: 
					 		 loadingTxt.setText(DynamicResource.installing); 
							break; 

					 	case CheckSoThread.STATUS_LOAD_SO: 
							loadingTxt.setText(DynamicResource.loading);
							break;
					 }
				}

				 
			}
		});
	}
	public void setShowProgress(int p,final String prosstxt){
		progress=p;
		this.runOnUiThread(new Runnable() {
			
			@Override
			public void run() { 
				
				if(progress==100){
					loadingTxt.setText(DynamicResource.loading);
				}else{ 
					loadingTxt.setText(prosstxt);
				}
				 
			}
		});
	}
     public static boolean pushMessage(String contentTitle,String contentText,int time,boolean bAddNumber,int nId,boolean bOnce) {
    	//if(true) return true;
    	Log.d("luan2", "--pushMessage");
    	//if(malpacaObj == null) return true;
    	long currentTime = System.currentTimeMillis();
    	NotificationMessage nmObj = new NotificationMessage();
    	nmObj.setMessage(contentText);
    	nmObj.setTime(time*convert+currentTime);
    	nmObj.setId(nId);
    	nmObj.setAddNumber(bAddNumber);
    	nmObj.setSpace(0);
    	nmObj.setIsOnce(bOnce);
    	
    	GlobalData sharedData = (GlobalData)appObj.getApplication();
    	sharedData.mMessageList.add(nmObj);
    	sharedData.saveNotificationList(appObj);
    	
    	return true;
    }
    
    public static boolean pushMessageWithSpace(String[] content,int num,int time,int nId,int space) {
    	//if(true) return true;
    	//for(int i = 0;i < num;i++) Log.v("cocos2d-x debug info", "璋���ㄥ�芥�板��:"+content[i]);
    	if(appObj == null) return true;
    	
    	long currentTime = System.currentTimeMillis();
    	NotificationMessage nmObj = new NotificationMessage();
    	nmObj.setMessage(content,num);
    	nmObj.setTime(time*convert+currentTime);
    	nmObj.setId(nId);
    	nmObj.setAddNumber(false);
    	nmObj.setSpace(space);
    	nmObj.setIsOnce(false);
    	
    	GlobalData sharedData = (GlobalData)appObj.getApplication();
    	sharedData.mMessageList.add(nmObj);
    	sharedData.saveNotificationList(appObj);
    	
    	return true;
    }
    
    public static boolean cleanNotificationById(int nId) {
    	//if(true) return true;
    	if(appObj == null) return true;
    	GlobalData sharedData = (GlobalData)appObj.getApplication();
    	
    	for(int i = 0,size = sharedData.mMessageList.size();i < size;i++) {
    		NotificationMessage nmes = sharedData.mMessageList.get(i);
    		if(nmes.getId() == nId) {
    			sharedData.mMessageList.remove(i);
    			i--;
    			size--;
    		}
    	}
    	
    	sharedData.clearNotificationMark(appObj);
		
    	return true;
    }
    
    public static boolean cleanNotificationByGroupId(int[] nId,int num) {
    	//if(true) return true;
    	//for(int i = 0;i < num;i++) Log.v("cocos2d-x debug info", "璋���ㄥ�芥�板��:"+nId[i]);
    	if(appObj == null) return true;
    
    	for(int i = 0;i < num;i++) cleanNotificationById(nId[i]);
		
    	return true;
    }
    
    public static boolean cleanAllNotification() {
    	Log.d("luan2", "--cleanAllNotification");
    	//if(true) return true;
    	if(appObj == null) return true;
    	//娓���ゆ����伴����ュ��琛�
    	GlobalData sharedData = (GlobalData)appObj.getApplication();
    	sharedData.mMessageList.clear();
    	
    	sharedData.clearNotificationMark(appObj);
		
    	return true;
	}
	private static native boolean nativeIsLandScape();
	private static native boolean nativeIsDebug();
	
}
