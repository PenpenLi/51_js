package td.utils;

public class TDCRC32 {
	
	static int[] m_Table = new int[256];;
	public static int Reflect(int ref, char ch)
	{
		int value = 0;

	    // Swap bit 0 for bit 7, bit 1 for bit 6, etc.
	    for(int i = 1; i < (ch + 1); i++)
	    {
	        if ((ref & 1) != 0)
	            value |= (1 << (ch - i));
	        ref >>>= 1;
	    }
	    return value;
	}
	
	static {
		// init CRC-32 table
	    // This is the official polynomial used by CRC-32
		int ulPolynomial = 0x04C11DB7;

	    // 256 values representing ASCII character codes.
	    for (int i = 0; i <= 0xFF; i++)
	    {
	        m_Table[i] = Reflect(i, (char) 8) << 24;
	        for (int j = 0; j < 8; j++) {
	            m_Table[i] = (m_Table[i] << 1) ^ (((m_Table[i] & (1 << 31)) != 0) ? ulPolynomial : 0);
	        }
	        m_Table[i] = Reflect(m_Table[i], (char) 32);
	    }

	}

    private int crc;

    /**
     * Creates a new CRC32 object.
     */
    public TDCRC32() {
    	crc = 0xFFFFFFFF;
    }

    /**
     * Updates the CRC-32 checksum with the specified byte (the low
     * eight bits of the argument b).
     *
     * @param b the byte to update the checksum with
     */
    public void update(int b) {
    	crc = m_Table[(int)(crc ^ b) & 0x000000ff] ^ (int)(crc >>> 8);
//    	System.out.println(crc);
    }

    /**
     * Updates the CRC-32 checksum with the specified array of bytes.
     */
    public void update(byte[] b, int off, int len) {
        if (b == null) {
        	System.out.println("is null off is " + off + " len is " + len);
            throw new NullPointerException();
        }
        if (off < 0 || len < 0 || off > b.length - len) {
            throw new ArrayIndexOutOfBoundsException();
        }
        for(int i = off; i < len; i++) {
        	update(b[i]);
        }
    }

    /**
     * Resets CRC-32 to initial value.
     */
    public void reset() {
        crc = 0;
    }

    /**
     * Returns CRC-32 value.
     */
    public long getValue() {
        return (long)crc & 0xffffffffL;
    }
}
