package com.motu.luan2;

import android.content.Context;
import android.content.res.Resources;

public class DynamicResource {

	static String app_name = "";
	static String downloading = "";
	static String update = "";
	static String lowVersion = "";
	static String checking = "";
	static String installing = "";
	static String loading = "";
	static String leaveMsg = "";
	static String confirm = "";
	static String cancel = "";
	static String checkNet = "";
	static String connectAgain = "";
	static String downloaded = "";
	static String fileDownloaded = "";
	static String downloadFailure = "";
	
	public static String product_name0 = "";
	public static String product_name1 = "";
	public static String product_name2 = "";
	public static String product_name3 = "";
	public static String product_name4 = "";
	public static String product_name5 = "";
	public static String product_name6 = "";
	public static String product_name7 = "";
	
	public static String product_desc0 = "";
	public static String product_desc1 = "";
	public static String product_desc2 = "";
	public static String product_desc3 = "";
	public static String product_desc4 = "";
	public static String product_desc5 = "";
	public static String product_desc6 = "";
	public static String product_desc7 = "";
	
	static int cancel_id=0;
	static int loading_txt_id=0;
	static int loadingBg_id=0;
	static int loadingIcon_id=0;
	static int loadingView_id=0;
	static int frameGameLayout_id=0;
	static int loading_icon_anim=0;
	static int loading_bg_anim=0;
	static int update_so_layout=0;
	static int update2_layout=0;
	static int update_layout=0;
	static int tvProcess_id=0;
	static int pbDownload_id=0;
	public void init(Context context) {
		Resources appResources = context.getResources();
		String packageName = context.getPackageName();
		app_name = context.getString(appResources.getIdentifier("app_name", "string",packageName));
		downloading = context.getString(appResources.getIdentifier("ldt_download", "string",packageName));
		update = context.getString(appResources.getIdentifier("ldt_update", "string",packageName));
		lowVersion = context.getString(appResources.getIdentifier("ldt_lowVersion", "string",packageName));
		checking = context.getString(appResources.getIdentifier("ldt_checking", "string",packageName));
		installing = context.getString(appResources.getIdentifier("ldt_installing", "string",packageName));
		loading = context.getString(appResources.getIdentifier("ldt_loading", "string",packageName));
		leaveMsg = context.getString(appResources.getIdentifier("ldt_leaveMsg", "string",packageName));
		confirm = context.getString(appResources.getIdentifier("ldt_confirm", "string",packageName));
		cancel = context.getString(appResources.getIdentifier("ldt_cancel", "string",packageName));
		checkNet = context.getString(appResources.getIdentifier("ldt_checkNet", "string",packageName));
		connectAgain = context.getString(appResources.getIdentifier("ldt_connectAgain", "string",packageName));
		downloaded = context.getString(appResources.getIdentifier("ldt_downloaded", "string",packageName));
		fileDownloaded = context.getString(appResources.getIdentifier("ldt_fileDownloaded", "string",packageName));
		downloadFailure = context.getString(appResources.getIdentifier("ldt_downloadFailure", "string",packageName));
		
		product_name0 = context.getString(appResources.getIdentifier("product_name0", "string",packageName));
		product_name1 = context.getString(appResources.getIdentifier("product_name1", "string",packageName));
		product_name2 = context.getString(appResources.getIdentifier("product_name2", "string",packageName));
		product_name3 = context.getString(appResources.getIdentifier("product_name3", "string",packageName));
		product_name4 = context.getString(appResources.getIdentifier("product_name4", "string",packageName));
		product_name5 = context.getString(appResources.getIdentifier("product_name5", "string",packageName));
		product_name6 = context.getString(appResources.getIdentifier("product_name6", "string",packageName));
		product_name7 = context.getString(appResources.getIdentifier("product_name7", "string",packageName));
		
		product_desc0 = context.getString(appResources.getIdentifier("product_desc0", "string",packageName));
		product_desc1 = context.getString(appResources.getIdentifier("product_desc1", "string",packageName));
		product_desc2 = context.getString(appResources.getIdentifier("product_desc2", "string",packageName));
		product_desc3 = context.getString(appResources.getIdentifier("product_desc3", "string",packageName));
		product_desc4 = context.getString(appResources.getIdentifier("product_desc4", "string",packageName));
		product_desc5 = context.getString(appResources.getIdentifier("product_desc5", "string",packageName));
		product_desc6 = context.getString(appResources.getIdentifier("product_desc6", "string",packageName));
		product_desc7 = context.getString(appResources.getIdentifier("product_desc7", "string",packageName));
		
		cancel_id = appResources.getIdentifier("cancel", "id",packageName);
		loading_txt_id = appResources.getIdentifier("loading_txt", "id",packageName);
		loadingBg_id = appResources.getIdentifier("loadingBg", "id",packageName);
		loadingIcon_id = appResources.getIdentifier("loadingIcon", "id",packageName);
		loadingView_id = appResources.getIdentifier("loadingView", "id",packageName);
		frameGameLayout_id = appResources.getIdentifier("frameGameLayout", "id",packageName);
		update2_layout = appResources.getIdentifier("update2", "layout",packageName);
		update_layout = appResources.getIdentifier("update", "layout",packageName);
		tvProcess_id = appResources.getIdentifier("tvProcess", "id",packageName);
  	  	pbDownload_id = appResources.getIdentifier("pbDownload", "id",packageName);
  	  	
		loading_icon_anim = appResources.getIdentifier("loading_icon", "anim",packageName);
		loading_bg_anim = appResources.getIdentifier("loading_bg", "anim",packageName);
		update_so_layout = appResources.getIdentifier("update_so", "layout",packageName);
	}

}
