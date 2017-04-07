package td.utils;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

public class CRC {

	public static String getCRC(File file) {
		FileInputStream inStream = null;
		DataInputStream in = null;
		try {
			inStream = new FileInputStream(file);
			in = new DataInputStream(inStream);
			TDCRC32 crc32 = new TDCRC32();
			byte[] data = new byte[4096];
			int len = -1;
			while ((len = in.read(data)) != -1) {
				crc32.update(data, 0, len);
			}
			return String.format("%08x", crc32.getValue());
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		} finally {
			try {
				if (inStream != null)
					inStream.close();
			} catch (IOException e) {
			}
			try {
				if (in != null)
					in.close();
			} catch (IOException e) {
			}
		}
	}
	
	public static String getCRC(InputStream in) {
		try {
			TDCRC32 crc32 = new TDCRC32();
			byte[] data = new byte[4096];
			int len = -1;
			while ((len = in.read(data)) != -1) {
				crc32.update(data, 0, len);
			}
			return String.format("%08x", crc32.getValue());
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
}
