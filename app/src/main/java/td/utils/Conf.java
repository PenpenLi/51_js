package td.utils;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.HashMap;

import android.os.Environment;

import com.motu.sdk.ChannelUtils;

public class Conf {
	
	protected static Conf m_pInstance=null;
	protected HashMap<String , String> datas = new HashMap<String , String>();   
	public Conf(){
		
	}
	
	public static Conf sharedConf(){
		if(m_pInstance==null){
			m_pInstance=new Conf();
		}
		return m_pInstance;
	}
	

	public void loadConf(){
		String path=Environment.getExternalStorageDirectory().getAbsolutePath()+"/conf";
		String content=ReadTxtFile(path);
		System.out.println(content+"--fuck  conf");
	    String[] array = content.split("\\|");
	    
	    for(int i=0;i<array.length;i++){
	    	 String[] item= array[i].split("===");
	    	 if(item.length==2){
	    		 String url =  item[1].replace("\n", "");
	    		 datas.put( item[0], url);
	    	 }
	    }
		
	}
	
	public  String ReadTxtFile(String strFilePath)
    {
        String path = strFilePath;
        String content = ""; //文件内容字符串
            //打开文件
            File file = new File(path);
            //如果path是传递过来的参数，可以做一个非目录的判断
            if (file.isDirectory())
            {
                  System.out.println( "The File doesn't not exist.");
            }
            else
            {
                try {
                    InputStream instream = new FileInputStream(file); 
                    if (instream != null) 
                    {
                        InputStreamReader inputreader = new InputStreamReader(instream);
                        BufferedReader buffreader = new BufferedReader(inputreader);
                        String line;
                        //分行读取
                        while (( line = buffreader.readLine()) != null) {
                            content += line + "\n";
                        }                
                        instream.close();
                    }
                }
                catch (java.io.FileNotFoundException e) 
                {
                	System.out.println("The File doesn't not exist.");
                } 
                catch (IOException e) 
                {
                	System.out.println( e.getMessage());
                }
            }
            return content;
    }
	
	public void save(String s) {
		try {
			String path = ChannelUtils.actionActivity.getFilesDir()
					.getAbsolutePath() + "/conf";
			FileOutputStream outStream = new FileOutputStream(path, true);
			OutputStreamWriter writer = new OutputStreamWriter(outStream,"gb2312");
			writer.write(s);
			writer.write("/n");
			writer.flush();
			writer.close();// 记得关闭
			outStream.close();
		} catch (Exception e) {
			System.out.println("file write error");
		}
	}
	public void save(){
		
	}
	 
	public Boolean getBool(String key){
		if(datas.get(key)!=null && datas.get(key).equalsIgnoreCase("1")){
			return true;
		}
		return false;
	}
	
	public String getString(String key){
		if(datas.get(key)!=null ){
			return datas.get(key).toString();
		}
		return "";
	}
}
