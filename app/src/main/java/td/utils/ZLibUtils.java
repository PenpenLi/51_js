package td.utils;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Enumeration;
import java.util.zip.Deflater;
import java.util.zip.DeflaterOutputStream;
import java.util.zip.Inflater;
import java.util.zip.InflaterInputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipException;
import java.util.zip.ZipFile;

/**
 * ZLib压缩工具
 */
public abstract class ZLibUtils {

	/**
	 * 压缩
	 * 
	 * @param data
	 *            待压缩数据
	 * @return byte[] 压缩后的数据
	 */
	public static byte[] compress(byte[] data) {
		byte[] output = new byte[0];

		Deflater compresser = new Deflater();

		compresser.reset();
		compresser.setInput(data);
		compresser.finish();
		ByteArrayOutputStream bos = new ByteArrayOutputStream(data.length);
		try {
			byte[] buf = new byte[1024];
			while (!compresser.finished()) {
				int i = compresser.deflate(buf);
				bos.write(buf, 0, i);
			}
			output = bos.toByteArray();
		} catch (Exception e) {
			output = data;
			e.printStackTrace();
		} finally {
			try {
				bos.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		compresser.end();
		return output;
	}

	/**
	 * 压缩
	 * 
	 * @param data
	 *            待压缩数据
	 * 
	 * @param os
	 *            输出流
	 */
	public static void compress(byte[] data, OutputStream os) {
		DeflaterOutputStream dos = new DeflaterOutputStream(os);

		try {
			dos.write(data, 0, data.length);

			dos.finish();

			dos.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public static byte[] tryDecompress(byte[] data) {
		byte[] output;
		try {
			output = decompress(data);
		} catch (OutOfMemoryError e) {
			System.gc();
			try {
				output = decompress(data);
			} catch (OutOfMemoryError e1) {
				output = data;
			}
			e.printStackTrace();
		}
		
		return output;
		
	}

	/**
	 * 解压缩
	 * 
	 * @param data
	 *            待压缩的数据
	 * @return byte[] 解压缩后的数据
	 */
	public static byte[] decompress(byte[] data) {
		byte[] output = new byte[0];

		Inflater decompresser = new Inflater();
		decompresser.reset();
		decompresser.setInput(data);
		ByteArrayOutputStream o = new ByteArrayOutputStream(data.length * 2);
		DataOutputStream dout = new DataOutputStream(o);
		try {
			byte[] buf = new byte[10240];
			while (!decompresser.finished()) {
				int i = decompresser.inflate(buf);
				dout.write(buf, 0, i);
			}
			output = o.toByteArray();
		} catch (Exception e) {
			output = data;
			e.printStackTrace();
		} finally {
			try {
				dout.close();
				o.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		decompresser.end();
		return output;
	}

	/**
	 * 解压缩
	 * 
	 * @param is
	 *            输入流
	 * @return byte[] 解压缩后的数据
	 */
	public static byte[] decompress(InputStream is) {
		InflaterInputStream iis = new InflaterInputStream(is);
		ByteArrayOutputStream o = new ByteArrayOutputStream(1024);
		try {
			int i = 1024;
			byte[] buf = new byte[i];

			while ((i = iis.read(buf, 0, i)) > 0) {
				o.write(buf, 0, i);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		return o.toByteArray();
	}
	
//	public static void zipFileString(String src, String dest) {
//		zipFile(new File(src), new File(dest));
//	}
	
    public static void zipFile(File source, File dest){
    	try {
    	 	if(!dest.exists()) {
        		dest.getParentFile().mkdirs();
        	}
        	FileInputStream input = new FileInputStream(source);
        	byte[] b = new byte[4096];
        	ByteArrayOutputStream bout = new ByteArrayOutputStream();
        	int len = 0;
        	while((len = input.read(b)) != -1) {
        		bout.write(b, 0, len);
        	}
        	byte[] result = ZLibUtils.compress(bout.toByteArray());
        	FileOutputStream fout = new FileOutputStream(dest);
        	fout.write(result);
        	input.close();
        	bout.close();
        	fout.close();
    	} catch (IOException e) {
			e.printStackTrace();
		}
    }
        
    public static File decompressTempFile(InputStream is, File TempFile) {
		InflaterInputStream iis = new InflaterInputStream(is);
		FileOutputStream o = null;
		try {
			o = new FileOutputStream(TempFile);
			int maxCount = 1024;
			int i = 1024;
			byte[] buf = new byte[maxCount];

			while ((i = iis.read(buf, 0, maxCount)) > 0) {
				o.write(buf, 0, i);
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				if(o != null) {
					o.close();
				}
				if(iis != null) {
					iis.close();
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return TempFile;
    }

    private static final int BUFF_SIZE = 1024 * 1024; // 1M Byte
    private static ProgressListener mProgressListener;
	public interface ProgressListener{
		void onProgress(float progress);
	}
	
	public static void setProgressListener(ProgressListener listener){
		mProgressListener=listener;
	}
	
	/**
	 * 解压缩一个文件
	 * 
	 * @param zipFile
	 *            压缩文件
	 * @param folderPath
	 *            解压缩的目标目录
	 * @throws IOException
	 *             当解压缩过程出错时抛出
	 */
	public static Boolean UnZipFolder(File zipFile, String folderPath){
		//解压obb
		try {
			File desDir = new File(folderPath);
			if (!desDir.exists()) {
				desDir.mkdirs();
			}
			ZipFile zf = new ZipFile(zipFile);
			mProgressListener.onProgress(0);
			FileInputStream fin=new FileInputStream(zipFile);
			int totalSpace=fin.available()/1024;//待解压文件总大小
			fin.close();
			int step=5;//更新进度条的间隔（5个文件更新一次）
			float currSpace=0;//当前解压进度
			byte buffer[] = new byte[BUFF_SIZE];
			Enumeration<?> entries = zf.entries();
			while (entries.hasMoreElements()) {
				ZipEntry entry = ((ZipEntry) entries.nextElement());
				InputStream in = zf.getInputStream(entry);
				//此处的File.separator 一定要和upZipFile()方法中的操作符保持一致，
				//也就是zipFile()方法要和upZipFile方法在同一平台下操作，否则路径斜杠会不一致 		
				String str = folderPath + File.separator + entry.getName();
	//			str = new String(str.getBytes("8859_1"), "GB2312");
				File desFile = new File(str);
				File fileParentDir = desFile.getParentFile();
				if (!fileParentDir.exists()) {
					fileParentDir.mkdirs();
				}
				if (entry.isDirectory()) {
					if (!desFile.exists()) {
						desFile.mkdir();
					}
					continue;
				}
				if (!desFile.exists()) {
					desFile.createNewFile();
				}
				if(step==0){
					mProgressListener.onProgress(currSpace/totalSpace);
					step=5;
				}
				step--;
				currSpace+=(in.available()/1024);			
				OutputStream out = new FileOutputStream(desFile);
				int length = 0;
				while ((length = in.read(buffer)) != -1) {
					out.write(buffer, 0, length);
				}
				out.flush();
				out.close();
				in.close();
			}
			mProgressListener.onProgress(totalSpace/totalSpace);
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			System.out.println("process obb fail");
			return false;
		}		
	}
	
}

