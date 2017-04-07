package td.utils;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.VideoView;

public class MediaView extends VideoView {
	
	public int px;
	public int py;
	public native static void videoPlayFinish();
	
	public MediaView(Context context) {
        super(context);
        // TODO Auto-generated constructor stub
    }
    public MediaView (Context context, AttributeSet attrs)
    {
        super(context,attrs);
    }
    public MediaView(Context context, AttributeSet attrs,int defStyle)
    {
        super(context,attrs,defStyle);
    }
    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
    {
    	  int width = getDefaultSize(0, widthMeasureSpec);
          int height = getDefaultSize(0, heightMeasureSpec);
//          int curWidth=0;
//          int curHeight=0;
//          if(width/480.0>height/640.0){
//          	curWidth=width;
//          	curHeight=(int) (curWidth/(480.0/640));
//          }else{
//          	curHeight=height;
//          	curWidth= (int) (curHeight*(480.0/640));
//          }
          setMeasuredDimension(width , height);  
          
//          px=(curWidth-width)/2;
//          py=(curHeight-height)/2;
          
 
  		 
//         ViewGroup parent=(ViewGroup)getParent();
//		 RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams)parent.getLayoutParams();
//		 params.leftMargin=(int) (-px);
//		 parent.setLayoutParams(params);
    }

}
