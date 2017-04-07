package td.utils;

import org.cocos2dx.lib.Cocos2dxHelper;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;

import com.motu.sdk.ChannelUtils;

public class Capture {

	public static void onCapture(){
		Bitmap mBitmap = BitmapFactory.decodeFile(Cocos2dxHelper.getCocos2dxWritablePath()+"/capture.jpg", null); 
		String url = MediaStore.Images.Media.insertImage(ChannelUtils.actionActivity.getContentResolver(), mBitmap, "", ""); 
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT){
			ChannelUtils.actionActivity.sendBroadcast(new Intent(Intent.ACTION_MEDIA_MOUNTED, Uri.parse("file://"+ Environment.getExternalStorageDirectory()))); 
		}
		else {
			MediaScannerConnection.scanFile(ChannelUtils.actionActivity, new String[]{
					Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM).getPath() + "/"}, null, null);
		}	
	}
}
