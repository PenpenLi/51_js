package com.motu.luan2;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;
import org.json.JSONObject;

import com.motu.sdk.ChannelAndroid;
 
public class GlobalFuntion {
	
	public static String getPayData(JSONObject jsonObj) {
		HttpPost httpRequest = new HttpPost(ChannelAndroid.getPaydataUrl);
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("platform", ChannelAndroid
				.getCurrentPlatform() + ""));
		String data = jsonObj.toString().replace("\"", "\\\"");
		params.add(new BasicNameValuePair("data", data));
		String resultjson = "{}";
		JSONObject strResultjson;
		try {
			httpRequest.setEntity(new UrlEncodedFormEntity(params, HTTP.UTF_8));
			HttpResponse httpResponse = new DefaultHttpClient()
					.execute(httpRequest);
			if (httpResponse.getStatusLine().getStatusCode() == 200) {
				resultjson = EntityUtils.toString(httpResponse
						.getEntity());
				try {
					strResultjson = new JSONObject(resultjson);
					if (strResultjson.getInt("ret") == 0) {
						resultjson = strResultjson.getString("reslut");
					}
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				System.out.println(resultjson);
			} else {
				System.out.println("Error Response"
						+ httpResponse.getStatusLine().toString());
			}
		} catch (ClientProtocolException e) {
			System.out.println(e.getMessage().toString());
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			System.out.println(e.getMessage().toString());
			e.printStackTrace();
		} catch (IOException e) {
			System.out.println(e.getMessage().toString());
			e.printStackTrace();
		}
		return resultjson;
	}
}