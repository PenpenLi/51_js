package com.motu.luan2;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Binder;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.widget.RemoteViews;

import com.motu.luan2.DownloadActivity.ICallbackResult;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

public class DownloadService extends Service {
	private static final int NOTIFY_ID = 621191142;
	private int progress;
	private NotificationManager mNotificationManager;
	private boolean canceled;
	/* ÏÂÔØ°ü°²×°Â·¾¶ */
	private static final String savePath = "/sdcard/luandoutang/";

	private static String saveFileName = "";//savePath + "ldt.apk";
	private ICallbackResult callback;
	private DownloadBinder binder;
	private boolean serviceIsDestroy = false;

	private double file_size = 0;//ÎÄ¼þ´óÐ¡
	private double down_size = 0;//ÒÑÏÂÔØ

	private Context mContext = this;
	private Handler mHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			// TODO Auto-generated method stub
			super.handleMessage(msg);
			switch (msg.what) {
				case 0:
					AppActivity.setDownload(false);
					// ÏÂÔØÍê±Ï
					// È¡ÏûÍ¨Öª
					mNotificationManager.cancel(NOTIFY_ID);
					installApk();
					break;
				case 2:
					AppActivity.setDownload(false);
					// ÕâÀïÊÇÓÃ»§½çÃæÊÖ¶¯È¡Ïû£¬ËùÒÔ»á¾­¹ýactivityµÄonDestroy();·½·¨
					// È¡ÏûÍ¨Öª
					mNotificationManager.cancel(NOTIFY_ID);
					break;
				case 1:
					int rate = msg.arg1;
					AppActivity.setDownload(true);
					if (rate < 100) {
						RemoteViews contentview = mNotification.contentView;
						//contentview.setTextViewText(R.id.tv_progress, rate + "%");
						//contentview.setProgressBar(R.id.progressbar, 100, rate, false);

						String sSize = "(" + String.format("%.2f", down_size) +"M/"+ String.format("%.2f", file_size) +"M)";

						contentview.setTextViewText(DynamicResource.tvProcess_id, DynamicResource.downloading+rate+"%"+sSize);
						contentview.setProgressBar(DynamicResource.pbDownload_id,100,rate,false);
					} else {
						System.out.println("ÏÂÔØÍê±Ï!!!!!!!!!!!");
						// ÏÂÔØÍê±Ïºó±ä»»Í¨ÖªÐÎÊ½
						mNotification.flags = Notification.FLAG_AUTO_CANCEL;
						mNotification.contentView = null;



						Intent intent = new Intent(mContext, DownloadActivity.class);
						// ¸æÖªÒÑÍê³É
						intent.putExtra("completed", "yes");
						// ¸üÐÂ²ÎÊý,×¢ÒâflagsÒªÊ¹ÓÃFLAG_UPDATE_CURRENT
						PendingIntent contentIntent = PendingIntent.getActivity(mContext, 0, intent,
								PendingIntent.FLAG_UPDATE_CURRENT);
						builder.setContentText(DynamicResource.downloaded);
						builder.setContentTitle(DynamicResource.fileDownloaded);
						builder.setContentIntent(contentIntent);
						mNotification=builder.build();

//					mNotification.setLatestEventInfo(mContext, DynamicResource.downloaded, DynamicResource.fileDownloaded, contentIntent);

						//
						serviceIsDestroy = true;
						stopSelf();// Í£µô·þÎñ×ÔÉí
					}
					mNotificationManager.notify(NOTIFY_ID, mNotification);
					break;
			}
		}
	};

	//
	// @Override
	// public int onStartCommand(Intent intent, int flags, int startId) {
	// // TODO Auto-generated method stub
	// return START_STICKY;
	// }

	@Override
	public IBinder onBind(Intent intent) {
		// TODO Auto-generated method stub
		System.out.println("ÊÇ·ñÖ´ÐÐÁË onBind");
		return binder;
	}

	@Override
	public void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		System.out.println("downloadservice ondestroy");
		// ¼ÙÈç±»Ïú»ÙÁË£¬ÎÞÂÛÈçºÎ¶¼Ä¬ÈÏÈ¡ÏûÁË¡£
		AppActivity.setDownload(false);
	}

	@Override
	public boolean onUnbind(Intent intent) {
		// TODO Auto-generated method stub
		System.out.println("downloadservice onUnbind");
		return super.onUnbind(intent);
	}

	@Override
	public void onRebind(Intent intent) {
		// TODO Auto-generated method stub

		super.onRebind(intent);
		System.out.println("downloadservice onRebind");
	}

	@Override
	public void onCreate() {
		// TODO Auto-generated method stub
		super.onCreate();
		binder = new DownloadBinder();
		mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
		//setForeground(true);// Õâ¸ö²»È·¶¨ÊÇ·ñÓÐ×÷ÓÃ
	}

	public class DownloadBinder extends Binder {
		public void start() {
			if (downLoadThread == null || !downLoadThread.isAlive()) {

				progress = 0;
				setUpNotification();
				new Thread() {
					public void run() {
						// ÏÂÔØ
						startDownload();
					};
				}.start();
			}
		}

		public void cancel() {
			canceled = true;
		}

		public int getProgress() {
			return progress;
		}

		public boolean isCanceled() {
			return canceled;
		}

		public boolean serviceIsDestroy() {
			return serviceIsDestroy;
		}

		public void cancelNotification() {
			mHandler.sendEmptyMessage(2);
		}

		public void addCallback(ICallbackResult callback) {
			DownloadService.this.callback = callback;
		}
	}

	private void startDownload() {
		// TODO Auto-generated method stub
		canceled = false;
		downloadApk();
	}

	//
	Notification mNotification;
	Notification.Builder builder ;
	// Í¨ÖªÀ¸
	/**
	 * ´´½¨Í¨Öª
	 */
	private void setUpNotification() {
		long when = System.currentTimeMillis();
//		mNotification = new Notification(icon, tickerText, when);
		builder=new Notification.Builder(mContext);
//		builder.setSmallIcon();
		builder.setWhen(when);



//		mNotification = new Notification();
//		mNotification.icon = android.R.drawable.stat_sys_download;
//		mNotification.when = when;


//		// ·ÅÖÃÔÚ"ÕýÔÚÔËÐÐ"À¸Ä¿ÖÐ
//		mNotification.flags = Notification.FLAG_ONGOING_EVENT;

		RemoteViews contentView = new RemoteViews(getPackageName(), DynamicResource.update_layout);
		// Ö¸¶¨¸öÐÔ»¯ÊÓÍ¼
//		mNotification.contentView = contentView;

		builder.setContent(contentView);

		Intent intent = new Intent(this, DownloadActivity.class);
		// ÏÂÃæÁ½¾äÊÇ ÔÚ°´homeºó£¬µã»÷Í¨ÖªÀ¸£¬·µ»ØÖ®Ç°activity ×´Ì¬;
		// ÓÐÏÂÃæÁ½¾äµÄ»°£¬¼ÙÈçservice»¹ÔÚºóÌ¨ÏÂÔØ£¬ ÔÚµã»÷³ÌÐòÍ¼Æ¬ÖØÐÂ½øÈë³ÌÐòÊ±£¬Ö±½Óµ½ÏÂÔØ½çÃæ£¬Ïàµ±ÓÚ°Ñ³ÌÐòMAIN Èë¿Ú¸ÄÁË - -
		// ÊÇÕâÃ´Àí½âÃ´¡£¡£¡£
		// intent.setAction(Intent.ACTION_MAIN);
		// intent.addCategory(Intent.CATEGORY_LAUNCHER);
		PendingIntent contentIntent = PendingIntent.getActivity(this, 0, intent,
				PendingIntent.FLAG_UPDATE_CURRENT);


		builder.setDefaults( Notification.FLAG_ONGOING_EVENT);
		builder.setContentIntent(contentIntent);
		builder.setSmallIcon(android.R.drawable.stat_sys_download);
		mNotification=builder.build();

		// ·ÅÖÃÔÚ"ÕýÔÚÔËÐÐ"À¸Ä¿ÖÐ
//		mNotification.flags = Notification.FLAG_ONGOING_EVENT;


		// Ö¸¶¨ÄÚÈÝÒâÍ¼
//		mNotification.contentIntent = contentIntent;
		mNotificationManager.notify(NOTIFY_ID, mNotification);


	}

	//
	/**
	 * ÏÂÔØapk
	 *
	 * @param url
	 */
	private Thread downLoadThread;

	private void downloadApk() {
		downLoadThread = new Thread(mdownApkRunnable);
		downLoadThread.start();
	}

	/**
	 * °²×°apk
	 *
	 * @param url
	 */
	private void installApk() {
		File apkfile = new File(saveFileName);
		if (!apkfile.exists()) {
			return;
		}
		Intent i = new Intent(Intent.ACTION_VIEW);
		i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		i.setDataAndType(Uri.parse("file://" + apkfile.toString()), "application/vnd.android.package-archive");
		mContext.startActivity(i);
		callback.OnBackResult("finish");
	}

	private int lastRate = 0;
	private Runnable mdownApkRunnable = new Runnable() {
		@Override
		public void run() {
			try {
				String sUrl = AppActivity.getDownloadUrl();
				URL url = new URL(AppActivity.getDownloadUrl());

				HttpURLConnection conn = (HttpURLConnection) url.openConnection();
				conn.connect();
				int length = conn.getContentLength();
				file_size = length/1024.0/1024.0;
				InputStream is = conn.getInputStream();

				File file = new File(savePath);
				if (!file.exists()) {
					file.mkdirs();
				}
				saveFileName = savePath + sUrl.substring(sUrl.lastIndexOf("/")+1);
				String apkFile = saveFileName;
				File ApkFile = new File(apkFile);
				FileOutputStream fos = new FileOutputStream(ApkFile);

				int count = 0;
				byte buf[] = new byte[1024];

				do {
					int numread = is.read(buf);
					count += numread;
					progress = (int) (((float) count / length) * 100);
					down_size = count/1024.0/1024.0;
					// ¸üÐÂ½ø¶È
					Message msg = mHandler.obtainMessage();
					msg.what = 1;
					msg.arg1 = progress;
					if (progress >= lastRate + 1) {
						mHandler.sendMessage(msg);
						lastRate = progress;
						if (callback != null)
							callback.OnBackResult(progress);
					}
					if (numread <= 0) {
						// ÏÂÔØÍê³ÉÍ¨Öª°²×°
						mHandler.sendEmptyMessage(0);
						// ÏÂÔØÍêÁË£¬cancelledÒ²ÒªÉèÖÃ
						canceled = true;
						break;
					}
					fos.write(buf, 0, numread);
				} while (!canceled);// µã»÷È¡Ïû¾ÍÍ£Ö¹ÏÂÔØ.

				fos.close();
				is.close();
			} catch (MalformedURLException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}

		}
	};

}
