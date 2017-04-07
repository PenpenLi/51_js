package com.motu.luan2.notification;
import java.io.Serializable;

public class NotificationMessage implements Serializable{

    private static final long serialVersionUID = -7060210544600464481L;   

    private String message = "";

	private long time = 0;

	private int id = 0;
	
	private boolean bAddNumber = false;
	
	private int space = 0;
	
	public String msgContent[]= new String[10];
	
	private int msgIdx = 0;
	
	private int msgNum = 0;
	
	private boolean bOnce = false;

	public String getMessage() {
		return message;
	}
	
	public String getMessage(int idx) {
		return msgContent[idx];
	}
	
	public void setMessage(String message) {
		this.message = message;
	}

	public void setMessage(String[] message,int num) {
		msgNum = num;
		for(int i = 0;i < num;i++) msgContent[i] = message[i];
	}
	
	public void setMsgIdx(int idx) {
		this.msgIdx = idx;
	}
	
	public int getMsgIdx() {
		return msgIdx;
	}
	
	public int getMsgNum() {
		return msgNum;
	}
	
	public long getTime() {
		return time;
	}

	public boolean getAddNumber() {
		return bAddNumber;
	} 
	public void setTime(long time) {
		this.time = time;
	}

	public int getId() {
		return id;
	}

	public int getSpace() {
		return space;
	}
	
	public void setId(int id) {
		this.id = id;
	}
	
	public void setAddNumber(boolean isAddNumber) {
		this.bAddNumber = isAddNumber;
	}
	
	public void setSpace(int space) {
		this.space = space;
	}
	
	public boolean getIsOnce() {
		return bOnce;
	}
	
	public void setIsOnce(boolean isOnce) {
		this.bOnce = isOnce;
	}

	public NotificationMessage() {
		super();
	}
}