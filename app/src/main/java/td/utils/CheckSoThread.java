package td.utils;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONObject;
import org.json.JSONTokener;
import android.content.Context;
import android.os.Build;
import com.motu.sdk.ChannelAndroid;
import com.motu.luan2.AppActivity;
import com.motu.luan2.ChannelBase;
import com.motu.sdk.ChannelUtils;

public class CheckSoThread extends Thread { 
	public static final byte STATUS_GET_SERVER_LIST	= 1;// 获取服务器列表
	public static final byte STATUS_ENTER_OBB = 2;		// 解压OBB
	public static final byte STATUS_CHECK_VERSION	= 3;// 检查版本
	public static final byte STATUS_DOWN_SO	= 4;// 检查更新包
	public static final byte STATUS_PACK_SO			= 5;// 操作完毕 
	public static final byte STATUS_LOAD_SO		= 6;// 载入更新包  


	public byte status = STATUS_GET_SERVER_LIST;// 步骤
 
	private String currCRC;  
	public String masterUrl; 
	public boolean running = false;
	public boolean isError = false;
	public boolean isPause = false; 
	public HttpClient httpClient = new DefaultHttpClient();  
	public HttpGet httpRequest = new HttpGet();  
	private static final int BLOCK_SIZE = 8192;
	public int tryWebCount=0;
	public CheckSoThread() {
		ensureLoadFd(); 
		ensureInitSo();

		
	}
	 
	@Override
	public void run() {
	
		
//		if(true){
//			enterGame();
//			return;
//		}
		
		tryWebCount=0;
		int tryDownCount=0;
		while (running ) {
			if(tryWebCount>=10||
			    tryDownCount>=4){
				break;
			}
			switch (status) { 
			case STATUS_GET_SERVER_LIST: 
				getServerList(); 
				break;
			case STATUS_ENTER_OBB:
				ChannelBase.enterUncompObb();
				status=STATUS_LOAD_SO;
				break;
			case STATUS_CHECK_VERSION:
				ChannelUtils.getActivity().setThreadStatus();
				checkWebVersion();
				tryWebCount++;
				break;
			case STATUS_DOWN_SO:
				downSo();
				tryDownCount++;
				break;
			case STATUS_PACK_SO:
				ChannelUtils.getActivity().setThreadStatus();
				packSo();
				break;
			case STATUS_LOAD_SO:
				ChannelUtils.getActivity().setThreadStatus();
				running=false;
				break; 
			}
		}
		if(!isError){ 
			enterGame();
		}
	}
	
	public void enterGame(){
		loadSo();
		ChannelUtils.getActivity().enterGame();
		
	}

	public  void ensureInitSo() { 
		File outputFile = new File(getSoPath());  
		if (outputFile.exists()) { 
			return;
		} 
		copyAssetsFromFile(ChannelUtils.getActivity(), Constants.SO_FILE, outputFile);
	 
	}
	
	public  void ensureLoadFd() {
		File outputFile = new File(getSoRoot() + "libfd.so"); 
		// 如果存储卡上已经存在So包，则直接跳过
		if (outputFile.exists()) {
			try {
				System.load(outputFile.getAbsolutePath()); 
				return;
			} catch (UnsatisfiedLinkError e) {
				e.printStackTrace();
			}
		}
		
		
		try {
			// 只有不存在才尝试从Jar包中拷贝
			copyAssetsFromFile(ChannelUtils.getActivity(), "libfd.so", outputFile);
			System.load(outputFile.getAbsolutePath()); 
			return;
		} catch (UnsatisfiedLinkError e) {
			e.printStackTrace();
		}
		try {
			System.loadLibrary("fd"); 
			return;
		} catch (UnsatisfiedLinkError e) {
			e.printStackTrace();
		}
	}
	
	private void checkSo() {
		String crc = getSoCrc();
 
		if(crc != null && crc.equalsIgnoreCase(Constants.LAST_CRC)) {
			status = STATUS_LOAD_SO;
		} else {
			status = STATUS_CHECK_VERSION;
		}
	}
	
	
	
	
	private void packSo() {
		File outputFile = new File(getDiffPath());
		if(Constants.IS_SO) {
			copyFile(outputFile, new File(getSoPath()));
		} else {
			BSDiff.bsdiffPatchFile(getDiffPath(), getSoPath(), getNewSoPath());
			copyFile(getNewSoPath(), getSoPath());
		}
		checkSo();
	}
	
	private void loadSo() { 
		/*if(ChannelAndroid.isIngoreDownload()){
			System.loadLibrary("game");
		}else{
			loadSo(getSoPath());
		}*/
		loadSo(getSoPath());
	}
	
	public   void loadSo(String path) {
		try {
			File outputFile = new File(path);
			if (outputFile.exists()){
				System.load(path); 
			}else{
				System.loadLibrary(Constants.SONAME);
			}
			return;
		} catch (UnsatisfiedLinkError e) {
			e.printStackTrace();
		}
	}
	

	
	private String getSoCrc() {
    	File soFile = new File(getSoPath());
    	String oldCrc = CRC.getCRC(soFile);
    	return oldCrc;
	}
	
	
	public  String readLocalServerList()
    {
        String path = AppActivity.getActivity().getFilesDir().getAbsolutePath()+"/serverlist.xml";
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

	public String inputStream2String(InputStream in) throws IOException {
		StringBuffer out = new StringBuffer();
		byte[] b = new byte[4096];
		for (int n; (n = in.read(b)) != -1;) {
			out.append(new String(b, 0, n));
		}
		return out.toString();
	}

	private void getServerList(){
		String urlString=ChannelAndroid.serverUrl; 
    	System.out.println(urlString+"--fuck  serverList");
    	if(status==STATUS_GET_SERVER_LIST && tryWebCount>3){
    		urlString=ChannelAndroid.backServerUrl;
    	}
    	
    	String serverListUrl=Conf.sharedConf().getString("g_serverlist_url");
    	if(serverListUrl.length()!=0){
    		urlString=serverListUrl;
    	}
    	
    	try {
			  httpRequest.setURI(new URI(urlString));
			  HttpResponse httpresponse = httpClient.execute(httpRequest); 
			  String inputData="";
			  inputData=inputStream2String(httpresponse.getEntity().getContent());
			  if (httpresponse.getStatusLine().getStatusCode() != HttpStatus.SC_OK) {
				  inputData = readLocalServerList();
			  };
			  	
		        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();  //取得DocumentBuilderFactory实例  
		        DocumentBuilder builder = factory.newDocumentBuilder(); //从factory获取DocumentBuilder实例  
		        org.w3c.dom.Document doc = builder.parse(new ByteArrayInputStream(inputData.getBytes("UTF-8")));   //解析输入流 得到Document实例  
		        org.w3c.dom.Element rootElement = doc.getDocumentElement();  
		        org.w3c.dom.NodeList items = rootElement.getElementsByTagName("masterserver");  

		        masterUrl="";
		        if(items.getLength()!=0){
		        	org.w3c.dom.Element item =(org.w3c.dom.Element) items.item(0);
		        	items=item.getElementsByTagName("address");//address 
		            if(items.getLength()!=0){
		            	item =(org.w3c.dom.Element) items.item(0); 
		            	masterUrl=item.getAttribute("url");
		            }
		        }
		                       
		        if(masterUrl.indexOf("http://")==-1){
		        	masterUrl="http://"+masterUrl;
		        }
		        

		       items = rootElement.getElementsByTagName("soserver");   
		       if(items.getLength()!=0){
		    	   org.w3c.dom.Element  item =(org.w3c.dom.Element) items.item(0); 
		    	   ChannelAndroid.soUpdateUrl=item.getAttribute("url"); 
	               
		       }
		       
		       items = rootElement.getElementsByTagName("obbserver");   
		       if(items.getLength()!=0){
		    	   org.w3c.dom.Element  item =(org.w3c.dom.Element) items.item(0); 
		    	   ChannelAndroid.obbPhpUrl=item.getAttribute("url"); 
	               
		       }
		       items = rootElement.getElementsByTagName("ext");
		       if(items.getLength()!=0){
		        	org.w3c.dom.Element item =(org.w3c.dom.Element) items.item(0);
		        	items=item.getElementsByTagName("address");//address 
		            if(items.getLength()!=0){
		            	item =(org.w3c.dom.Element) items.item(0); 
		            	ChannelAndroid.paynotifyUrl=item.getAttribute("url");
		            }
		        }
		       items = rootElement.getElementsByTagName("payData");
		       if(items.getLength()!=0){
		        	org.w3c.dom.Element item =(org.w3c.dom.Element) items.item(0);
		        	items=item.getElementsByTagName("address");//address 
		            if(items.getLength()!=0){
		            	item =(org.w3c.dom.Element) items.item(0); 
		            	ChannelAndroid.getPaydataUrl=item.getAttribute("url");
		            }
		        }
		       
		       if(ChannelAndroid.soUpdateUrl.indexOf("http://")==-1){
		    	   ChannelAndroid.soUpdateUrl="http://"+ChannelAndroid.soUpdateUrl;
		       }
		       
		       int ServerVersion=0;
		       items = rootElement.getElementsByTagName("version");   
		       if(items.getLength()!=0){
		    	   org.w3c.dom.Element  item =(org.w3c.dom.Element) items.item(0); 
		    	   ServerVersion=Integer.parseInt(item.getAttribute("ver")); 
	               
		       } 
		       
		       
		       if(ChannelAndroid.versionCode< ServerVersion){
		    	   
	            	String inputLine = null;  
	                String content="";        	
	            	urlString = masterUrl+"?type=99&platform=" + ChannelAndroid.currPlatform+"&channel="+ChannelAndroid.adId+"&ver="+ChannelAndroid.versionCode;
	            	
	            	System.out.println(urlString+"--fuck check cover install");
	            	 
	            	 httpRequest.setURI(new URI(urlString));  
	            	 httpresponse = httpClient.execute(httpRequest);   
	                
	                //in = new InputStreamReader(conn.getInputStream());  
	            	 InputStreamReader in = new InputStreamReader(httpresponse.getEntity().getContent());  
	    	        // 为输出创建BufferedReader  
	            	 BufferedReader buffer = new BufferedReader(in);  
	                inputLine = null;  
	                content="";
	                while (((inputLine = buffer.readLine()) != null))  
	                {   
	                	content += inputLine ;
	                }            
	                in.close();  
	                JSONTokener jsonParser = new JSONTokener(content);   
	                JSONObject response = (JSONObject) jsonParser.nextValue();  

	                String apkPath=response.getString("url");
	                if (apkPath == null || apkPath.isEmpty()) {
	                	System.out.println(apkPath+"--fuck--empty url");
	                	status=STATUS_ENTER_OBB; 
			    		return;
					}
	                
	                running=false;
	            	isError=true;
	                System.out.println(apkPath+"--fuck--install url");
	                String urltype=response.getString("urltype");
	            	ChannelUtils.getActivity().setNeedUpdate(apkPath,urltype.equalsIgnoreCase("1"));
	            	return;
	            }
				status=STATUS_ENTER_OBB;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			tryWebCount++;
			e.printStackTrace();
		}  
      
	}
	
	private void checkWebVersion() {
        try {
        	File jarFile = new File(getSoPath());
	    	if (!jarFile.exists()) {
	    		currCRC="";
	    	} else {
	    		currCRC = CRC.getCRC(jarFile);
	    	}
	    	
        	
        	
        	String phpUrl=Conf.sharedConf().getString("g_lib_url");
        	if(phpUrl.length()!=0){
        		ChannelAndroid.soUpdateUrl=phpUrl;
        	}
        	
 
        	
        	String urlString = ChannelAndroid.soUpdateUrl + "?crc=" + currCRC;
        	
        	System.out.println(urlString+"--fuck check_so"); 
            /*HttpURLConnection conn = (HttpURLConnection) url.openConnection(); 
            if (Build.VERSION.SDK != null && Build.VERSION.SDK_INT > 13) {
            	conn.setRequestProperty("Connection", "close");
            }
            conn.setDoInput(true);
            conn.setUseCaches(false); 
            conn.setRequestMethod("GET");
			conn.setConnectTimeout(20000);
            conn.connect();
*/
             httpRequest.setURI(new URI(urlString));  
	         HttpResponse httpresponse = httpClient.execute(httpRequest);  
            
            InputStreamReader in = new InputStreamReader(httpresponse.getEntity().getContent());  
            // 为输出创建BufferedReader  
            BufferedReader buffer = new BufferedReader(in);  
            String inputLine = null;  
            String content="";
            while (((inputLine = buffer.readLine()) != null))  
            {   
            	content += inputLine ;
            }            
            in.close();  
                    
            JSONTokener jsonParser = new JSONTokener(content);   
            JSONObject response = (JSONObject) jsonParser.nextValue();  
                      
            Constants.LAST_CRC = response.getString("last_crc");
            Constants.LAST_PATH =response.getString("down_path");
            Constants.IS_SO = response.getInt("is_so")==1;
            Constants.PUBLISH_TIME = response.getInt("publish_time");
            
            
            
            
    		System.out.println("assets  crc "+getAssetSoCrc());
    		System.out.println("curr crc "+currCRC);
			System.out.println("last  crc "+Constants.LAST_CRC );
			System.out.println("local publish  time "+ChannelAndroid.ignoreUpdate );
			System.out.println("server publish  time "+Constants.PUBLISH_TIME );
			
            if (currCRC != null && (currCRC.equalsIgnoreCase(Constants.LAST_CRC))) {
            	 if( ChannelAndroid.ignoreUpdate> Constants.PUBLISH_TIME ){  
             		File outputSoFile = new File(getSoPath());  
             		if(outputSoFile.exists()){
             			outputSoFile.delete();
             			System.out.println("delete old so");
             		}
         			System.out.println("copy asset so");
         		    outputSoFile = new File(getSoPath()); 
             		copyAssetsFromFile(ChannelUtils.getActivity(), Constants.SO_FILE, outputSoFile);
                 	status = STATUS_LOAD_SO;
         			System.out.println("load so" );
                 }else{ 
                 	status = STATUS_LOAD_SO;
                 }
            } else { 
        		
        		
                if(getAssetSoCrc().equalsIgnoreCase(Constants.LAST_CRC) || ChannelAndroid.ignoreUpdate> Constants.PUBLISH_TIME ){  
            		File outputSoFile = new File(getSoPath());  
            		if(outputSoFile.exists()){
            			outputSoFile.delete();
            			System.out.println("delete old so");
            		}
        			System.out.println("copy asset so");
        		    outputSoFile = new File(getSoPath()); 
            		copyAssetsFromFile(ChannelUtils.getActivity(), Constants.SO_FILE, outputSoFile);
                	status = STATUS_LOAD_SO;
        			System.out.println("load so" );
                }else{

        			System.out.println("down load so" );
            		status = STATUS_DOWN_SO;
                }

            } 
        } catch (Exception e) {
        	e.printStackTrace();
        	try {
     			Thread.sleep(1000);
     		} catch (InterruptedException e1) {
     		}
        }
    }


	
	private void downSo() {
		try { 
			String urlString = Constants.LAST_PATH; 
            URL url = new URL(urlString);
            System.out.println(urlString+"---fuck");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection(); 
            if (Build.VERSION.SDK != null && Build.VERSION.SDK_INT > 13) {
            	conn.setRequestProperty("Connection", "close");
            }
            conn.connect();

            int contentLength = Integer.parseInt(conn.getHeaderField("Content-Length"));
            File outputFile = new File(getDiffPath());
            if (!outputFile.getParentFile().exists())
            	outputFile.getParentFile().mkdirs();
            DataOutputStream dos = new DataOutputStream(new FileOutputStream(outputFile));
            
            
            DataInputStream dis = new DataInputStream(conn.getInputStream());
            byte[] data = new byte[BLOCK_SIZE];
            int len = -1;
            float sum = 0;
            float progress=0;
            while ((len = dis.read(data)) > 0) {
            	dos.write(data, 0, len);
            	sum += len;
				progress = (sum * 100) / contentLength;
				ChannelUtils.getActivity().setShowProgress((int)progress,String.format("%05.2f%%",progress));
            }
            dos.flush();
            dos.close();
            dis.close(); 
            if(Constants.IS_SO ) {
            	unzipOneFile(outputFile);
            } 
            status = STATUS_PACK_SO;
        } catch (Exception e) { 
        	e.printStackTrace();
            try {
    			Thread.sleep(1000);
    		} catch (InterruptedException e1) {
    		}
        }
	}
	
	
	private String getNewSoPath() {
		return getSoRoot() + Constants.NEW_FILE;
	}
	
	private String getDiffPath() {
		return getSoRoot() + Constants.DIFF_FILE;
	}
	
	private String getSoPath() {
		return getSoRoot() + Constants.SO_FILE;
	}
	
	
	public  String getAssetSoCrc() { 
		try {
			InputStream in;
			in = ChannelUtils.getActivity().getAssets().open(Constants.SO_FILE);
			return CRC.getCRC(in);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
		return "";
	}
	 
	/** 从Jar包中拷贝文件 */
	public  File copyAssetsFromFile(Context context, String name, File outputFile) {
		byte[] data = new byte[BLOCK_SIZE];
		try {
			if (!outputFile.getParentFile().exists())
				outputFile.getParentFile().mkdirs();
			
			InputStream in = context.getAssets().open(name);
			DataOutputStream dos = new DataOutputStream(new FileOutputStream(outputFile));
			
			int len = -1;
			while ((len = in.read(data)) != -1) {
				dos.write(data, 0, len);
			}
			dos.flush();
			dos.close();
			in.close();
			return outputFile;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public  String getSoRoot() {
	    	String result = null;
	    	if(ChannelUtils.getActivity() != null) {
	    		result=ChannelUtils.getActivity().getFilesDir().getAbsolutePath()+"/so_path/"; 
	    	} else {
	    		result = "";
	    	}
	    	return result;
	    }

	private File copyFile(String src, String dest) {
		return copyFile(new File(src), new File(dest));
	}
	
	private File copyFile(File src, File dest) {
		try {
			File outputFile = dest;
			if (!outputFile.getParentFile().exists())
				outputFile.getParentFile().mkdirs();

			
			InputStream in = new FileInputStream(src);
			DataOutputStream dos = new DataOutputStream(new FileOutputStream(outputFile));
			byte[] data = new byte[BLOCK_SIZE];
			int len = -1;
			while ((len = in.read(data)) != -1) {
				dos.write(data, 0, len);
			}
			dos.flush();
			dos.close();
			in.close();
			return outputFile;
		} catch (Exception e) {
			return null;
		}
	}
	
	
	  
	  public static boolean deleteDir(File dir) {
	       if (dir.isDirectory()) {
	           String[] children = dir.list();
	           //递归删除目录中的子目录下
	           for (int i=0; i<children.length; i++) {
	               boolean success = deleteDir(new File(dir, children[i]));
	               if (!success) {
	                   return false;
	               }
	           }
	       }
	       // 目录此时为空，可以删除
	       return dir.delete();
	  }
	   
	   
    public  int unzipOneFile(File source){
    	try {
        	FileInputStream input = new FileInputStream(source);
        	File dest = new File(getSoRoot() + "/zip.xxxTemp");
        	if(dest.exists()) {
        		deleteDir(dest);
        	}
        	if(!dest.exists()) {
        		dest.getParentFile().mkdirs();
        	}
        	File out = ZLibUtils.decompressTempFile(input, dest);
        	copyFile(out, source);
        	out.delete();
    	} catch (IOException e) {
			e.printStackTrace();
			return -1;
		}
    	return 0;
    }
    
}
