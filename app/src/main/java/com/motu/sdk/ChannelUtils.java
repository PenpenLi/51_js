package com.motu.sdk;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.cocos2dx.lib.Cocos2dxHelper;
import android.app.ActivityManager;
import android.app.ActivityManager.RunningAppProcessInfo;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.telephony.TelephonyManager;
import android.util.Log;

import com.motu.luan2.AppActivity;

public class ChannelUtils {
	public static AppActivity actionActivity = null;
	public static Boolean isInited=false;
	public static Boolean isLogined=false;
	public static Boolean isNeedShowLogin=false;
	public static String loginParam = "";
	public static AppActivity getActivity() {
		return actionActivity;
	}
	
	public static void onInitedRespone(final String str){ 
		isInited=true;
		if( isNeedShowLogin){
			isNeedShowLogin=false;
		    showLoginView(loginParam);
		}
		
		
		nativeInitRespone(str);
	}
	
	
	public static void showLoginView(final String param) { 
		loginParam = param;
		getActivity().runOnUiThread(new Runnable() {
			
			@Override
			public void run() { 
				if(isInited){
	        	  ChannelAndroid.sharePlatform().showLoginView(loginParam);
	     		}else{
	    	 		isNeedShowLogin=true;
	     		}
			}
		});
	}
	public static void initChannel(String param) {
		final String tempString=param;
		getActivity().runOnUiThread(new Runnable() {
			
			@Override
			public void run() { 

				ChannelAndroid.sharePlatform().init(tempString);
				
			}
		});
	}
	public  static void onLogoutRespone(){
		isLogined=false;
		Cocos2dxGLSurfaceView view = Cocos2dxGLSurfaceView.getInstance();
		if(view != null) {
			view.queueEvent(new Runnable() {
				@Override
				public void run() {
					ChannelUtils.nativeLogoutRespone();
				}
			});
		}
//		getActivity().runOnUiThread(new Runnable() {
//			
//			@Override
//			public void run() { 
//				ChannelUtils.nativeLogoutRespone();
//			}
//		});
	}
	
	public  static void onPayRespone(final String str){
		Cocos2dxGLSurfaceView view = Cocos2dxGLSurfaceView.getInstance();
		if(view != null) {
			view.queueEvent(new Runnable() {
				@Override
				public void run() {
					ChannelUtils.nativePayRespone(str);
				}
			});
		}
	}
 
	public  static void onLoginRespone(final String name, final String password, final String session, final String ext){
		isLogined=true;
		Cocos2dxGLSurfaceView view = Cocos2dxGLSurfaceView.getInstance();
		if(view != null) {
			view.queueEvent(new Runnable() {
				@Override
				public void run() {
					nativeLoginRespone(  name,   password,   session,ext);
				}
			});
		}
	}
	
	public static void logout(){
		AppActivity.getActivity().runOnUiThread(new Runnable() {
			public void run() {
				ChannelAndroid.sharePlatform().logout();
		}});
	}
	
	public static void roleInitFinish(final String roleid, final String serverid,final String rolelevel,final String rolename,final String ext){
		AppActivity.getActivity().runOnUiThread(new Runnable() {
			public void run() {
				ChannelAndroid.sharePlatform().roleInitFinish( roleid,  serverid,  rolelevel, rolename, ext);
		}});
		
	}
	
	public static void finishNewGuid(final String ext){
		AppActivity.getActivity().runOnUiThread(new Runnable() {
			public void run() {
				ChannelAndroid.sharePlatform().finishNewGuid(ext);
		}});
	}
	public static void pay(final String chargeNum, final String orderId,final String productId, final String roleId, final String serverId, final String ext3) { 
		AppActivity.getActivity().runOnUiThread(new Runnable() {
			public void run() {
				ChannelAndroid.sharePlatform().pay(chargeNum,orderId,productId,roleId,serverId,ext3);
		}});
	}

	public static void extenInter(final String type,final String ext ){ 
		AppActivity.getActivity().runOnUiThread(new Runnable() {
			public void run() {
				ChannelAndroid.sharePlatform().extenInter(type,ext);
		}});
	}
	
	public  static void onExtenInterRespone(final String type, final String ext){
		Cocos2dxGLSurfaceView view = Cocos2dxGLSurfaceView.getInstance();
		if(view != null) {
			view.queueEvent(new Runnable() {
				@Override
				public void run() {
					nativeExtenInterRespone(type, ext);
				}
			});
		}
	}
	
    public static void enterGame(final String roleid,final String serverid,final String rolelevel,final String rolename,final String remark,final String ext){
    	AppActivity.getActivity().runOnUiThread(new Runnable() {
			public void run() {
				ChannelAndroid.sharePlatform().enterGame(roleid,  serverid, rolelevel, rolename, remark,ext);
		}});
    }
    
    
	public static void userCenter() {
		AppActivity.getActivity().runOnUiThread(new Runnable() {
			public void run() {
				ChannelAndroid.sharePlatform().userCenter();
		}});
	} 
	
	/**
	 * 判断App是否在前台运行
	 * @return
	 */
	public static boolean isAppOnForeground() {
		ActivityManager activityManager = (ActivityManager)  ChannelUtils.getActivity().getApplicationContext()
				.getSystemService(Context.ACTIVITY_SERVICE);
		String packageName = ChannelUtils.getActivity().getApplicationContext().getPackageName();
		List<RunningAppProcessInfo> appProcesses = activityManager.getRunningAppProcesses();
		if (appProcesses == null)
			return false;
		for (RunningAppProcessInfo appProcess : appProcesses) {
			if (appProcess.processName.equals(packageName)
					&& appProcess.importance == RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
				return true;
			}
		}
		return false;
	} 
	
	public static void loginOutInOpenGL() {
		Cocos2dxGLSurfaceView view = Cocos2dxGLSurfaceView.getInstance();
		if(view != null) {
			view.queueEvent(new Runnable() {
				@Override
				public void run() {
					ChannelUtils.nativeLogoutRespone();
				}
			});
		}
	}
	
	
	
	public static void exitApplication() {
		Cocos2dxHelper.stopAllEffects();
		Cocos2dxHelper.stopBackgroundMusic();
	
		ChannelAndroid.sharePlatform().platformExit();
		android.os.Process.killProcess(android.os.Process.myPid()); //获取PID
		System.exit(0); //常规java、c#的标准退出法，返回值为0代表正常退出
	}
	

	/************************************************************************/
	/* 0未检测，1表示Wifi，2表示2g，3表示3g，4，未知网络 ,5表示无网络                 */
	/************************************************************************/
	public static int getNetStatus() {
	    ConnectivityManager connMgr =  
	            (ConnectivityManager) getActivity().getSystemService(Context.CONNECTIVITY_SERVICE);  

	    int netStatus = 0;
	    NetworkInfo activeInfo = connMgr.getActiveNetworkInfo();  
	    if (activeInfo != null && activeInfo.isConnected()) {
	    	if(activeInfo.getType() == ConnectivityManager.TYPE_WIFI) {
	    		netStatus = 1;
	    	} else if(activeInfo.getType() == ConnectivityManager.TYPE_MOBILE) {
	    		if(activeInfo.getSubtype() == TelephonyManager.NETWORK_TYPE_EVDO_A) {
	    			netStatus = 3;
	    		} else if(activeInfo.getSubtype() == TelephonyManager.NETWORK_TYPE_CDMA) {
	    			netStatus = 2;
	    		} else if(activeInfo.getSubtype() == TelephonyManager.NETWORK_TYPE_EDGE) {
	    			netStatus = 2;
	    		} else if(activeInfo.getSubtype() == TelephonyManager.NETWORK_TYPE_GPRS) {
	    			netStatus = 2;
	    		} else {
	    			netStatus = 4;
	    		}

	    	} 
	    } else {  
	    	netStatus = 5;
	    } 
		return netStatus;
	}
	
	public static String getNetCarrier() {
		
	    ConnectivityManager connMgr =  
	            (ConnectivityManager) getActivity().getSystemService(Context.CONNECTIVITY_SERVICE);  

	    String netCarrier = "";
	    NetworkInfo activeInfo = connMgr.getActiveNetworkInfo();  
	    if (activeInfo != null && activeInfo.isConnected()) {
	    	if(activeInfo.getType() == ConnectivityManager.TYPE_WIFI) {
	    		netCarrier = "WIFI";
	    	} else if(activeInfo.getType() == ConnectivityManager.TYPE_MOBILE) {
	    		if(activeInfo.getSubtype() == TelephonyManager.NETWORK_TYPE_EVDO_A) {
	    			netCarrier = "中国电信";
	    		} else if(activeInfo.getSubtype() == TelephonyManager.NETWORK_TYPE_CDMA) {
	    			netCarrier = "中国电信";
	    		} else if(activeInfo.getSubtype() == TelephonyManager.NETWORK_TYPE_EDGE) {
	    			netCarrier = "中国移动";
	    		} else if(activeInfo.getSubtype() == TelephonyManager.NETWORK_TYPE_GPRS) {
	    			netCarrier = "中国联通";
	    		} else {
	    			netCarrier = activeInfo.getSubtypeName();
	    		}

	    	} 
	    } else {  
	    	netCarrier = "无网络";
	    } 
		return netCarrier;
	}
	
	public static void restartPackage() {

		ChannelAndroid.sharePlatform().platformExit();
		Intent i = getActivity().getBaseContext().getPackageManager()  
		        .getLaunchIntentForPackage(getActivity().getBaseContext().getPackageName());  
		i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);  
		getActivity().startActivity(i);
		getActivity().finish();
		System.exit(0);
		 
	}/** 
	 * 检查指定apk是否已经安装 
	 * @param context       上下文 
	 * @param packageName   apk包名 
	 * @return       
	 */  
	public static boolean isAppInstalled(Context context,String packageName) {  
	    PackageManager pm = context.getPackageManager();  
	    boolean installed =false;  
	    try {  
	        pm.getPackageInfo(packageName,PackageManager.GET_ACTIVITIES);  
	        installed =true;  
	    } catch(PackageManager.NameNotFoundException e) {  
	        //捕捉到异常,说明未安装  
	        installed =false;  
	    }  
	    return installed;  
	}  
	public static native void nativeInitRespone(String result);
	public static native void nativeLoginRespone(String name, String password, String session, String ext);
	public static native void nativeSetChannel(int channel);
	public static native void nativeSetPlatform(int platform);
	public static native void nativeSetChannelParams(int param1,int param2,int param3,String url1,String backurl1,String url2);
	public static native void nativeLogoutRespone(); 
	public static native void nativeShareRespone(); 
	public static native void nativePayRespone(String result); 
	public static native void nativeSetAssetsUpdateUrl(String url); 
	public static native void nativeSetAdId(String url);
	public static native void nativeSetExtendFilePath(String extendPath);
	public static native void nativeExtenInterRespone(String type,String ext);
}
