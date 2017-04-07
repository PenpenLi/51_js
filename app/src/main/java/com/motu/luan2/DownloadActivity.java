package com.motu.luan2;
 
import td.utils.Constants;
import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.util.DisplayMetrics;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.LinearInterpolator;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.motu.luan2.DownloadService.DownloadBinder;
import com.motu.sdk.ChannelUtils;
public class DownloadActivity extends Activity {
	private Button btn_cancel;// btn_update, 
	private DownloadBinder binder;
	private boolean isBinded; 
	private boolean isDestroy = true;

	private ImageView loadingBg;
	private TextView loadingTxt;
	private ImageView loadingIcon; 

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(DynamicResource.update2_layout);
		
		btn_cancel = (Button) findViewById(DynamicResource.cancel_id);
		loadingTxt = (TextView) findViewById(DynamicResource.loading_txt_id);
		loadingBg=(ImageView) findViewById(DynamicResource.loadingBg_id);
		loadingIcon = (ImageView) findViewById(DynamicResource.loadingIcon_id);
		loadingTxt.setText(DynamicResource.loading); 
		Constants.context=this;
			
		 DisplayMetrics dm = new DisplayMetrics();
		 ChannelUtils.getActivity().getWindowManager().getDefaultDisplay().getMetrics(dm); 
		 int  sH = dm.heightPixels; 
		 float density=dm.density;
		 
		 RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams)loadingIcon.getLayoutParams();
		 params.bottomMargin=sH*10/20;
		 loadingIcon.setLayoutParams(params);
		 

		 params = (RelativeLayout.LayoutParams)loadingBg.getLayoutParams();
		 params.bottomMargin=sH*10/20;
		 loadingBg.setLayoutParams(params);
		 loadingBg.setScaleX(PlatformInfo.getScaleSize());
		 loadingBg.setScaleY(PlatformInfo.getScaleSize());
		 
		 params = (RelativeLayout.LayoutParams)loadingTxt.getLayoutParams();
		 params.bottomMargin=(sH*9)/20;
		 loadingTxt.setLayoutParams(params);
		 

		 params = (RelativeLayout.LayoutParams)btn_cancel.getLayoutParams();
		 params.bottomMargin=(sH*6)/20;
		 btn_cancel.setLayoutParams(params);
		 
		 Animation operatingAnim = AnimationUtils.loadAnimation(this, DynamicResource.loading_bg_anim);  
		 LinearInterpolator lin = new LinearInterpolator();  
		 operatingAnim.setInterpolator(lin);  
		 loadingBg.startAnimation(operatingAnim);  
		
		 operatingAnim = AnimationUtils.loadAnimation(this, DynamicResource.loading_icon_anim);  
		  lin = new LinearInterpolator();  
		 operatingAnim.setInterpolator(lin);  
		 loadingIcon.setScaleX(PlatformInfo.getScaleSize());
		 loadingIcon.setScaleY(PlatformInfo.getScaleSize());
		 loadingIcon.startAnimation(operatingAnim);  
		 
		btn_cancel.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				binder.cancel();
				binder.cancelNotification();
				finish();
			}
		});
	}
	

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
//		// TODO Auto-generated method stub
		return true;
	}

	ServiceConnection conn = new ServiceConnection() {

		@Override
		public void onServiceDisconnected(ComponentName name) {
			// TODO Auto-generated method stub
			isBinded = false;
		}

		@Override
		public void onServiceConnected(ComponentName name, IBinder service) {
			// TODO Auto-generated method stub
			binder = (DownloadBinder) service;
			System.out.println("服务启动!!!");
			// 开始下载
			isBinded = true;
			binder.addCallback(callback);
			binder.start();

		}
	};

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		if (isDestroy && AppActivity.isDownload()) {
			Intent it = new Intent(DownloadActivity.this, DownloadService.class);
			startService(it);
			bindService(it, conn, Context.BIND_AUTO_CREATE);
		}
		System.out.println(" notification  onresume");
	}

	@Override
	protected void onNewIntent(Intent intent) {
		// TODO Auto-generated method stub
		super.onNewIntent(intent);
		if (isDestroy && AppActivity.isDownload()) {
			Intent it = new Intent(DownloadActivity.this, DownloadService.class);
			startService(it);
			bindService(it, conn, Context.BIND_AUTO_CREATE);
		}
		System.out.println(" notification  onNewIntent");
	}

	@Override
	protected void onStart() {
		// TODO Auto-generated method stub
		super.onStart();

	}

	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
		System.out.println(" notification  onPause");
	}

	@Override
	protected void onStop() {
		// TODO Auto-generated method stub
		super.onStop();
		isDestroy = false;
		System.out.println(" notification  onStop");
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		if (isBinded) {
			System.out.println(" onDestroy   unbindservice");
			unbindService(conn);
		}
		if (binder != null && binder.isCanceled()) {
			System.out.println(" onDestroy  stopservice");
			Intent it = new Intent(this, DownloadService.class);
			stopService(it);
		}
	}

	private ICallbackResult callback = new ICallbackResult() {

		@Override
		public void OnBackResult(Object result) {
			// TODO Auto-generated method stub
			if ("finish".equals(result)) {
				finish();
				return;
			}
			int i = (Integer) result;
			//mProgressBar.setProgress(i);
			// tv_progress.setText("当前进度 =>  "+i+"%");
			// tv_progress.postInvalidate();
			mHandler.sendEmptyMessage(i);
		}

	};

	private Handler mHandler = new Handler() {
		public void handleMessage(android.os.Message msg) {
			loadingTxt.setText(DynamicResource.downloading + msg.what + "%");
		};
	};

	public interface ICallbackResult {
		public void OnBackResult(Object result);
	}
}
