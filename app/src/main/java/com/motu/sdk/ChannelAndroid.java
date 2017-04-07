package com.motu.sdk;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import org.json.JSONException;
import org.json.JSONObject;
import com.motu.luan2.AppActivity;
import com.motu.luan2.ChannelBase;
import com.motu.luan2.DynamicResource;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Bundle;

public class ChannelAndroid {
	
	public static int  CHANNEL_ANDROID_MOTU=1;
	public static int  CHANNEL_ANDROID_GFMOTU=2;
	
	public static int  CHANNEL_ANDROID_START=1999;
    //S级
	public static int  CHANNEL_ANDROID_TENCENT=2000;
	public static int  CHANNEL_ANDROID_360=2001;
	public static int  CHANNEL_ANDROID_MI=2002;
	public static int  CHANNEL_ANDROID_BAIDU=2003;
	public static int  CHANNEL_ANDROID_UC=2004;
	public static int  CHANNEL_ANDROID_DOUBLEMI=2005;
	//A级
	public static int  CHANNEL_ANDROID_YUWAN=2010;
	public static int  CHANNEL_ANDROID_37WAN=2011;
	public static int  CHANNEL_ANDROID_KAOPU=2012;
	public static int  CHANNEL_ANDROID_HUAWEI=2013;
	public static int  CHANNEL_ANDROID_OPPO=2014;
	public static int  CHANNEL_ANDROID_VIVO=2015;
	public static int  CHANNEL_ANDROID_LENOVO=2016;
	public static int  CHANNEL_ANDROID_KUPAI=2017;
	public static int  CHANNEL_ANDROID_JINLI=2018;
	public static int  CHANNEL_ANDROID_PPS=2019;
	public static int  CHANNEL_ANDROID_BILIBILI=2020;
	public static int  CHANNEL_ANDROID_MEIZU=2021;
	public static int  CHANNEL_ANDROID_YIDONG=2022;
	public static int  CHANNEL_ANDROID_DIANXIN=2023;
	public static int  CHANNEL_ANDROID_LINYOU=2024;
	public static int  CHANNEL_ANDROID_GFAN=2025;
    //B级
	public static int  CHANNEL_ANDROID_LIANTONG=2030;
	public static int  CHANNEL_ANDROID_4399=2031;
	public static int  CHANNEL_ANDROID_WANDOUJIA=2032;
	public static int  CHANNEL_ANDROID_ANZHI=2033;
	public static int  CHANNEL_ANDROID_YOUKU=2034;
	public static int  CHANNEL_ANDROID_PPTV=2035;
	public static int  CHANNEL_ANDROID_LESHI=2036;
	public static int  CHANNEL_ANDROID_MUZHIWAN=2037;
	public static int  CHANNEL_ANDROID_XINLANG=2038;
	public static int  CHANNEL_ANDROID_PENGYOUWAN=2039;
	public static int  CHANNEL_ANDROID_RENXINYOU=2040;
	public static int  CHANNEL_ANDROID_LEWAN=2041;
	public static int  CHANNEL_ANDROID_EFUNZH=2042;
	public static int  CHANNEL_ANDROID_XX=2043;
	public static int  CHANNEL_ANDROID_TT=2044;
	public static int  CHANNEL_ANDROID_DANGLE=2045;
	public static int  CHANNEL_ANDROID_CHONGCHONG=2046;
	public static int  CHANNEL_ANDROID_ANQU=2047;
    //C级
	public static int  CHANNEL_ANDROID_YOUMI=2050;
	public static int  CHANNEL_ANDROID_YOUXIQUN=2051;
	public static int  CHANNEL_ANDROID_YOULONG=2052;
	public static int  CHANNEL_ANDROID_07073=2053;
	public static int  CHANNEL_ANDROID_SHOUMENG=2054;
	public static int  CHANNEL_ANDROID_8868=2055;
	public static int  CHANNEL_ANDROID_MOMO=2056;
	public static int  CHANNEL_ANDROID_LINGJING=2057;
	public static int  CHANNEL_ANDROID_QUICK=2058;
	public static int  CHANNEL_ANDROID_SHUOWAN=2059;
	public static int  CHANNEL_ANDROID_SHUNWAN=2060;
	public static int  CHANNEL_ANDROID_YONGSHI=2061;
	public static int  CHANNEL_ANDROID_XIANXIA=2062;
	public static int  CHANNEL_ANDROID_LEYOU=2063;
	public static int  CHANNEL_ANDROID_ZHANGYUE=2064;
	public static int  CHANNEL_ANDROID_XIAO7=2065;
	public static int  CHANNEL_ANDROID_DIANYOU=2067;
	public static int  CHANNEL_ANDROID_LONGXIA=2068;
	public static int  CHANNEL_ANDROID_KUAIFA=2069;
	public static int  CHANNEL_ANDROID_KDBS=2070;
	public static int  CHANNEL_ANDROID_HANFENG=2071;
	public static int  CHANNEL_ANDROID_CHANGBA=2072;
	public static int  CHANNEL_ANDROID_YOUXIFAN=2073;
	public static int  CHANNEL_ANDROID_JINSHI=2074;
	public static int  CHANNEL_ANDROID_END=2100;
	
	//海外渠道ID3000以上
	public static int  CHANNEL_HAIWAI_START=3000;
	
	public static int  CHANNEL_HW_ANDROID_START=3100;
	public static int  CHANNEL_ANDROID_EFUNTWGP=3101;
	public static int  CHANNEL_ANDROID_EFUNTWGW=3102;
	public static int  CHANNEL_ANDROID_EFUNHK=3103;
	public static int  CHANNEL_ANDROID_VN=3104;
	public static int  CHANNEL_ANDROI_EFUNENCN=3105;
	public static int  CHANNEL_ANDROI_EFUNENCN_LY=3106;
	public static int  CHANNEL_ANDROID_MEAST=3107;
	public static int  CHANNEL_ANDROID_IDN=3108;
	public static int  CHANNEL_ANDROID_VEGA_VN=3109;
	
	public static int currPlatform = 0;
	public static int currChannel = 0;
	public static int isMotuAccount = 0;
	public static int isLangangSystem = 0;
	public static int hasUserCenter = 0;
	public static int ignoreUpdate = 0;
	public static int versionCode = 0;
	public static Boolean selfUpdate = false;
	public static boolean hasObb = false;

	public static String serverPhpUrl="";
	public static String obbPhpUrl="";
	public static String paynotifyUrl="http://123.59.142.36:8800/3GuoPay_";
	public static String getPaydataUrl="";
	public static String serverUrl="" ;
	public static String backServerUrl="http://123.59.134.106:8000/ldt2_android/serverlist.xml" ;
	public static String assetsUpdateUrl="" ;
	public static String soUpdateUrl ="";
	public static String apkUpdateUrl="" ;
	public static String adId ="0";
	
	
	public static boolean hasInited=false;
	public static void setPlatform(int iplatform) {
		currPlatform = iplatform;
	}
	
    public static String getMetaValue(Context context, String metaKey) {
        Bundle metaData = null;
        String apiKey = null;
        if (context == null || metaKey == null) {
            return null;
        }
        try {
            ApplicationInfo ai = context.getPackageManager()
                    .getApplicationInfo(context.getPackageName(),
                            PackageManager.GET_META_DATA);
            if (null != ai) {
                metaData = ai.metaData;
            }
            if (null != metaData) {
                apiKey = metaData.getString(metaKey);
            }
        } catch (NameNotFoundException e) {

        }
        return apiKey;
    }
    
    public static String getProductName(int index){
    	String productName="";
    	switch (index){
    	 	case 0: 
    	 		productName=DynamicResource.product_name0;
    	 		break;
    	 	case 1: 
    	 		productName=DynamicResource.product_name1;
    	 		break;
    	 	case 2: 
    	 		productName=DynamicResource.product_name2;
    	 		break;
    	 	case 3: 
    	 		productName=DynamicResource.product_name3;
    	 		break;
    	 	case 4: 
    	 		productName=DynamicResource.product_name4;
    	 		break;
    	 	case 5: 
    	 		productName=DynamicResource.product_name5;
    	 		break;
    	 	case 6: 
    	 		productName=DynamicResource.product_name6;
    	 		break;
    	 	case 7: 
    	 		productName=DynamicResource.product_name7;
    	 		break;
    	   default :
    		   break;
    	}
    	return productName;
    }
    public static String getProductDesc(int iapid) {
		String productDesc = "";		
		switch (iapid) {
		case 0: 
			productDesc=DynamicResource.product_desc0;
	 		break;
	 	case 1: 
	 		productDesc=DynamicResource.product_desc1;
	 		break;
	 	case 2: 
	 		productDesc=DynamicResource.product_desc2;
	 		break;
	 	case 3: 
	 		productDesc=DynamicResource.product_desc3;
	 		break;
	 	case 4: 
	 		productDesc=DynamicResource.product_desc4;
	 		break;
	 	case 5: 
	 		productDesc=DynamicResource.product_desc5;
	 		break;
	 	case 6: 
	 		productDesc=DynamicResource.product_desc6;
	 		break;
	 	case 7: 
	 		productDesc=DynamicResource.product_desc7;
	 		break;
		default:
		    break;
		}
		return productDesc;
	}
	public static void setChannelPraram(){
		initChannelParam();
		ChannelUtils.nativeSetChannel(ChannelAndroid.currChannel);
		ChannelUtils.nativeSetPlatform(ChannelAndroid.currPlatform);
		ChannelUtils.nativeSetChannelParams(
				ChannelAndroid.isMotuAccount,
				ChannelAndroid.isLangangSystem,
				ChannelAndroid.hasUserCenter,
				ChannelAndroid.serverUrl,
				ChannelAndroid.backServerUrl,
				ChannelAndroid.serverPhpUrl
				);
		ChannelUtils.nativeSetAdId(adId);
		ChannelUtils.nativeSetAssetsUpdateUrl(assetsUpdateUrl);
	}
	
	public static String getFromAssets(String fileName){ 
		String fileContext="";
		try { 
            InputStreamReader inputReader = new InputStreamReader(AppActivity.getContext().getResources().getAssets().open(fileName) ); 
            BufferedReader bufReader = new BufferedReader(inputReader);
            String line="";            
            while((line = bufReader.readLine()) != null)
            	fileContext += line;           
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
		return fileContext;
	}
	
	public static void initChannelParam(){
		if(hasInited){
			return;
		}	
		try {
		    ApplicationInfo appInfo = ChannelUtils.getActivity().getPackageManager()
                    .getApplicationInfo(ChannelUtils.getActivity().getPackageName(), 
            PackageManager.GET_META_DATA);

			String msg=String.valueOf(appInfo.metaData.get("ADID"));
			if(msg.length()!=0){ 
				adId=msg.substring(1,msg.length());
			} 
			
			msg=String.valueOf(appInfo.metaData.get("IGNORE_UPDATE_SO"));
			if(msg.length()!=0){ 
				ignoreUpdate=Integer.parseInt(msg.substring(1,msg.length()));
			} 
			msg=String.valueOf(appInfo.metaData.get("SO_VERSION"));
			versionCode=Integer.parseInt(msg); 
			
		} catch (NameNotFoundException e) {
			e.printStackTrace();
		}
		
	
		String context = getFromAssets("channelCfg.json");
		if (context.isEmpty()) {
			System.out.println("not channelCfg.json");
		}
		try {
			JSONObject json=new JSONObject(context);

			if (json.has("MOTU_ACCOUNT")) {
				isMotuAccount=Integer.parseInt(json.get("MOTU_ACCOUNT").toString());
			}

			if (json.has("HASOBB")){
				hasObb = Integer.parseInt(json.get("HASOBB").toString())==1;
			}
			
			if (json.has("SERVER_URL")) {
				serverUrl=json.get("SERVER_URL").toString();
			}
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		hasInited=true;
	}
	
	public static int getCurrentPlatform() {
		initChannelParam();
		return currPlatform;
	}
	
	public static boolean isIngoreDownload() { 
		initChannelParam();
		return ignoreUpdate==1;
	}
	
	
	private static ChannelBase platform = null;
	public static synchronized ChannelBase sharePlatform() {
		if(platform != null) {
			return platform;
		}
		if(platform == null) {
			currPlatform = getCurrentPlatform();
			platform = new ChannelBase(){}; 
		}
		return platform;
	}
	
	 
}
