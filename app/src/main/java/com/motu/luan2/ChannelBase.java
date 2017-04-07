package com.motu.luan2;

import com.tendcloud.tenddata.TalkingDataGA;

import java.util.Date;
import java.util.HashMap;
import java.util.TreeMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


import com.motu.sdk.ChannelAndroid;
import com.motu.sdk.ChannelUtils;

import android.app.ProgressDialog;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.YuvImage;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.widget.EditText;
import android.widget.Toast;

public abstract class ChannelBase {

	public ChannelBase() {
		ChannelAndroid.setPlatform(ChannelAndroid.CHANNEL_ANDROID_JINSHI);
	}


	private boolean hasinit = false;
	private String orderid = "0";

	public void init(String param) {

	}

	public void logout() {

	}

	public void showLoginView(String param) {

	}

	public void roleInitFinish(String roleid, String serverid,
			String rolelevel, String rolename, String ext) {
	}

	public void extenInter(String type, String ext) {
	}

	public void enterGame(String roleid, String serverid, String rolelevel,
			String rolename, String remark, String ext) {
	}

	public void shareFeed(String link, String prictureURL, String name,
			String caption, String description, String ext) {

	}

	public void moreRecharge(String roleid, String serverid, String rolelevel,
			String rolename, String remark, String ext) {

	}

	public void pay(final String chargeNum, final String orderId, final String productId,
			final String roleId, final String serverId, final String ext3) {
	}

	public void userCenter() {

	}
	
	public void submitExtraData(final int type,final String id,final String name,final String level,final String gendar,final String serverId, final String serverName) {
	}

	public void finishNewGuid(String ext) {
		System.out.println("finishNewGuid");
	}

	public void activityCreate(Bundle savedInstanceState) {
	}

	public void activityPause() {
	}

	public void activityStop() {
	}

	public void activityResume() {
	}

	public void onNewIntent(Intent intent) {
	}

	public void activityOnReStart() {
	}

	public void activityOnStart() {
	}

	public boolean activityResult(int requestCode, int resultCode, Intent data) {
		return true;
	}

	public void saveInstanceState(Bundle outState) {
	}

	public void activityDestory() {
	}

	public void activityConfigurationChanged(Configuration newConfig) {
	}

	public void platformExit() {

	}

	public boolean activityExist() {
		return false;
	}

	public void keybackActivity() {
	}
	

	
	public void activityBackPressed(){
	}

	public void onRequestPermissionsResult(int requestCode,
			String[] permissions, int[] grantResults) {

	}

	private ProgressDialog progressDialog;

	protected void showLoading() {
		progressDialog = new ProgressDialog(ChannelUtils.getActivity());
		progressDialog.setMessage("正在加载...");
		progressDialog.setIndeterminate(true);
		progressDialog.setCancelable(false);
		progressDialog.show();
	}

	protected void showLoading(String tips) {
		progressDialog = new ProgressDialog(ChannelUtils.getActivity());
		progressDialog.setMessage(tips);
		progressDialog.setIndeterminate(true);
		progressDialog.setCancelable(false);
		progressDialog.show();
	}

	protected void hideLoading() {
		if (progressDialog != null) {
			progressDialog.cancel();
			progressDialog = null;
		}
	}

	/**
	 * 进行网络检查
	 */
	public boolean checkNetwork() {
		return false;

	}

	public static void addObbSearchPath() {

	}

	// 解压obb文件
	public static void enterUncompObb() {
	}

//	private void verify() {
//		if (TextUtils.isEmpty(sid)) {
//			Toast.makeText(ChannelUtils.getActivity(), "请先进行登录",
//					Toast.LENGTH_LONG).show();
//			return;
//		}
//		HttpProgressAsyncTask task = new HttpProgressAsyncTask(
//				ChannelUtils.getActivity(), vurl, "正在进行验证……") {
//			protected void onHandleResult(JSONObject message)
//					throws JSONException {
//				String status = message.getString("status");
//				if ("YHYZ_000".equals(status)) {
//					uid = message.getString("userId");
//					nsdk.showToolBar(ChannelUtils.getActivity());
//					JSONObject json = new JSONObject();
//					try {
//						json.put("channel", nsdk.getChannel());
//						json.put("sdkVersion", nsdk.getSdkVersion());
//					} catch (JSONException e) {
//						// TODO Auto-generated catch block
//						e.printStackTrace();
//					}
//
//					ChannelUtils.onLoginRespone(username, uid, sid, json.toString());
//				} else {
//					Toast.makeText(ChannelUtils.getActivity(),
//							message.getString("msg"), Toast.LENGTH_LONG).show();
//				}
//			}
//
//			@Override
//			protected void onHandleError(String msg) {
//				Toast.makeText(ChannelUtils.getActivity(), "验证异常：" + msg,
//						Toast.LENGTH_LONG).show();
//			}
//		};
//		VerifyBean bean = new VerifyBean();
//		bean.gameId = appinfo.appId;
//		bean.sid = sid;
//		bean.userId = uid;
//		bean.channel = nsdk.getChannel();
//		bean.version = nsdk.getSdkVersion();
//		task.execute(bean.toJson(appinfo.appKey));
//	}

}
