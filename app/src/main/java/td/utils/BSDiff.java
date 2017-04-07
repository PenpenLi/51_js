package td.utils;

public class BSDiff {
	

	public static native void bsdiffCreatePatch(String patchFile, String oldFile, String newFile);
	public static native void bsdiffPatchFile(String patchFile, String oldFile, String newFile);
	

}
