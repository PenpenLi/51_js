package td.utils;

import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;

public class GpsLocation {

	public double latitude=0.0;
	public double longitude =0.0;
	
	public LocationManager locationManager;

	public LocationListener locationListener =null;
	private static native void setGpsLocation(final int latitude,final int longitude);
	private static native void setGpsLocationError(final int errorCode);
	
	public void onLocationGet(){ 
		setGpsLocation((int)(latitude*1000000),(int)(longitude*10000));
	}
	
	public void stopLocation(){
		if(locationListener!=null)
		{
			locationManager.removeUpdates(locationListener);
		}
	}
	
	public void getLocation(LocationManager _locationManager,int time,int distance){
		locationManager=_locationManager;
		if(locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)){
			Location location = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
			if(location != null){
				latitude = location.getLatitude(); //经度   
				longitude = location.getLongitude(); //纬度
				onLocationGet();
			}
		}else{
			 locationListener = new LocationListener() { 
				// Provider的状态在可用、暂时不可用和无服务三个状态直接切换时触发此函数
				@Override
				public void onStatusChanged(String provider, int status, Bundle extras) {
					
				}
				
				// Provider被enable时触发此函数，比如GPS被打开
				@Override
				public void onProviderEnabled(String provider) {
					
				}
				
				// Provider被disable时触发此函数，比如GPS被关闭 
				@Override
				public void onProviderDisabled(String provider) {
					
				}
				
				//当坐标改变时触发此函数，如果Provider传进相同的坐标，它就不会被触发 
				@Override
				public void onLocationChanged(Location location) {
					if (location != null) {   
						latitude = location.getLatitude(); //经度   
						longitude = location.getLongitude(); //纬度
						onLocationGet();
					}
				}
			}; 
		
			locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER,time*1000, distance,locationListener);   
			Location location = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);   
			if(location != null){    
					latitude = location.getLatitude(); //经度   
					longitude = location.getLongitude(); //纬度 
					onLocationGet();
				}   
			}
	}
}
