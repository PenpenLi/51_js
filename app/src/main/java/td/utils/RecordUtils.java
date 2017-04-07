package td.utils;
 

import java.io.File;
import java.io.IOException;

import android.media.MediaRecorder;
 

public class RecordUtils {
	
	public static MediaRecorder mediaRecorder ;
	 
	public static void startRecord(String path){
		if(mediaRecorder!=null){
			return;
		}
		System.out.println("start record: "+path);
		mediaRecorder = new MediaRecorder();  
		// 第1步：设置音频来源（MIC表示麦克风）  
		mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);  
		//第2步：设置音频输出格式（默认的输出格式）  
		mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.DEFAULT);  
		//第3步：设置音频编码方式（默认的编码方式）  
		mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.DEFAULT);  
		//创建一个临时的音频输出文件  
		File audioFile=null;
		audioFile =new  File(path);
			//第4步：指定音频输出文件  
		mediaRecorder.setOutputFile(audioFile.getAbsolutePath());  
	 
		//第5步：调用prepare方法  
		try {
			mediaRecorder.prepare();
		} catch (IllegalStateException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}  
		//第6步：调用start方法开始录音  
		mediaRecorder.start();  
	}
	
	
	public static void stopRecord(){
		System.out.println("stop record");
		if(mediaRecorder==null){
			return;
		}
		
		mediaRecorder.stop();
		mediaRecorder.release();
		mediaRecorder=null;
		
	}

}
