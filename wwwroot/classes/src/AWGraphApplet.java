/*
 * @(#)Graph3Dapplet.java 1.0 03/11/03
 *
 */

import java.awt.*;
import java.applet.*;
//import awgraphapplet.logs.*;


public class AWGraphApplet extends java.applet.Applet {
	
    private static final int VERTICAL = 0;
    private static final int HORIZONTAL = 1;
    private static final int SOLID = 0;
    private static final int STRIPED = 1;

	private static final int DEBUG=3;
	private static final int SHIFTBAR=3;

    private String title;
    private Font font;
    private FontMetrics metrics;
    private int orientation;
    private int barsize;

    private int nbblocks;
    private String blabels[];
	private int b_fontsize=11;
    private int blockSpacing = 5;
	
    private int nbvalues;
    private Color colors[];
    private String vlabels[];
    private int styles[];
    private float max[];
    private int valSpacing = 0;
    private int valWidth = 5;

    private float values[][];

    private int maxLabelWidth = 0;
	private Color background_color = Color.white;
	private Color border_color = Color.white;
	private Color backgraph_colorl = Color.decode("#F6F6F6");
	private Color backgraph_colorm = Color.decode("#EDEDED");
	private Color backgraph_colorh = Color.decode("#E0E0E0");


//    public synchronized void init() {
    public synchronized void start() {
//        Trace.init(DEBUG,"");
//        Trace.debug(0,"Applet init",getClass().getName());
  
        String temp = getParameter("b_fontsize");
        if (temp != null) { b_fontsize = Integer.parseInt(temp); }
		
        title = getParameter("title");
        if (title == null) { title = "Chart"; }
        
        temp = getParameter("nbblocks");
        if (temp != null) { nbblocks = Integer.parseInt(temp); }

        temp = getParameter("nbvalues");
        if (temp != null) { nbvalues = Integer.parseInt(temp); }
        
        temp = getParameter("blockspacing");
        if (temp != null) { blockSpacing = Integer.parseInt(temp); }
        temp = getParameter("valspacing");
        if (temp != null) { valSpacing = Integer.parseInt(temp); }
        temp = getParameter("valwidth");
        if (temp != null) { valWidth = Integer.parseInt(temp); }

        temp = getParameter("orientation");
        if (temp == null) { orientation = VERTICAL; }
        else if (temp.equalsIgnoreCase("horizontal")) { orientation = HORIZONTAL; }
        else { orientation = VERTICAL; }
        temp = getParameter("barsize");
        if (temp != null) { barsize = Integer.parseInt(temp); }

		temp = getParameter("background_color");
        if (temp != null) { background_color = Color.decode("#"+temp); }
		temp = getParameter("border_color");
        if (temp != null) { border_color = Color.decode("#"+temp); }

        font = new java.awt.Font("Verdana", 0, b_fontsize);
        metrics = getFontMetrics(font);
        
//        Trace.debug(1,"nbblocks "+nbblocks,getClass().getName());
//        Trace.debug(1,"nbvalues "+nbvalues,getClass().getName());
//        Trace.debug(1,"barsize "+barsize,getClass().getName());
        
        blabels = new String[nbblocks];
        vlabels = new String[nbvalues];
        styles = new int[nbvalues];
        max = new float[nbvalues];
        colors = new Color[nbvalues];
        values = new float[nbblocks][nbvalues];

        for (int i=0; i < nbvalues; i++) {
            parseLabel(i);
            parseStyle(i);
            parseColor(i);
            parseMax(i);
        }
        for (int j=0; j < nbblocks; j++) {
            parsebLabel(j);
            parseValue(j);
		}
        for (int i=0; i < nbvalues; i++) {
			if (max[i]<=0) { max[i]=1; }
//			Trace.debug(2,"max["+i+"]="+max[i],getClass().getName());
		}
    }
            
    private synchronized void parsebLabel(int i) {
        String temp = getParameter("b" + (i+1) + "_label");
        if (temp==null) {
            blabels[i] = "";
        } else {
            blabels[i] = temp;
        }
        maxLabelWidth = Math.max(metrics.stringWidth ((String) (blabels[i])), maxLabelWidth);
    }

    private synchronized void parseLabel(int i) {
        String temp = getParameter("v" + (i+1) + "_label");
        if (temp==null) {
            vlabels[i] = "";
        } else {
            vlabels[i] = temp;
        }
    }

    private synchronized void parseStyle(int i) {
        String temp = getParameter("v" + (i+1) + "_style");
        if (temp == null || temp.equalsIgnoreCase("solid")) {
            styles[i] = SOLID;
        } else if (temp.equalsIgnoreCase("striped")) {
            styles[i] = STRIPED;
        } else {
            styles[i] = SOLID;
        }
    }
    
    private synchronized void parseColor(int i) {
        String temp = getParameter("v" + (i+1) + "_color");
        if (temp != null) {
            colors[i] = Color.decode("#"+temp);
        } else {
            colors[i] = Color.gray;
        }
    }

    private synchronized void parseMax(int i) {
        String temp = getParameter("v" + (i+1) + "_max");
        if (temp != null) {
            max[i] = Float.parseFloat(temp);
        } else {
            max[i] = 1;
        }
    }

    private synchronized void parseValue(int j) {
        String temp = getParameter("b" + (j+1));
		if (temp != null) {
        	String[] ss=temp.split(" ",0);
        	for (int i=0; i<ss.length; i++) {
				//Trace.debug(2,"ss="+ss[i],getClass().getName());
	            values[j][i] = Float.parseFloat(ss[i]);
				//Trace.debug(2,"values["+j+"]["+i+"]="+values[j][i],getClass().getName());
			}
	    }
    }

    
    public synchronized void paint(Graphics g) {

		// background and border
		g.setColor(background_color);
		g.fillRect(0,0,getSize().width-1,getSize().height-1);
		g.setColor(border_color);
		g.drawRect(0,0,getSize().width-1,getSize().height-1);
		
		// draw the bars and their titles
		if(orientation == HORIZONTAL) { paintHorizontal(g); }
		else { paintVertical(g); }
    }
        
	private synchronized void draw3DBar(Graphics g,int x, int y, float w, float h, int shift, Color c) {
		// Draw a 3D bar at pos (x,y)
		Polygon p = new Polygon();
		int width=new Float(w).intValue();
		int height=new Float(h).intValue();
		//Trace.debug(2,"draw3DBar "+x+","+y+","+w+"=>"+width+","+h+"=>"+height,getClass().getName());
		
		p.addPoint(x,y);p.addPoint(x+width,y);
		p.addPoint(x+width,y-height);p.addPoint(x,y-height);
		g.setColor(c); g.fillPolygon(p); g.setColor(c.darker());
		g.drawPolygon(p);
		Polygon p2 = new Polygon();
		p2.addPoint(x+width,y);p2.addPoint(x+width+shift,y-shift);
		p2.addPoint(x+width+shift,y-shift-height);p2.addPoint(x+width,y-height);
		g.setColor(c.darker()); g.fillPolygon(p2); g.setColor(c.darker().darker());
		g.drawPolygon(p2);
		Polygon p3 = new Polygon();
		p3.addPoint(x,y-height);p3.addPoint(x+width,y-height);
		p3.addPoint(x+width+shift,y-height-shift);p3.addPoint(x+shift,y-height-shift);
		g.setColor(c); g.fillPolygon(p3); g.setColor(c.darker());
		g.drawPolygon(p3);
 	}

    private synchronized void paintHorizontal(Graphics g) {

    }
    
    private synchronized void paintVertical(Graphics g) {

		Font font = new java.awt.Font("Verdana", 0, b_fontsize);
		FontMetrics metrics = getFontMetrics(font);
		g.setColor(Color.black);
		g.setFont(font);

		int shift=10;
		int allbarwidth=(((nbvalues*(valWidth+valSpacing))+blockSpacing)*nbblocks);
		int allbarheight=barsize;
		int axepointx=(getSize().width-allbarwidth)/2 - 2*shift;
        int axepointy = getSize().height - (2*metrics.getHeight()) - metrics.getDescent();

		int cx=axepointx;
		int cy=axepointy;

		// Draw axes
		Polygon p = new Polygon();
		p.addPoint(cx,cy);p.addPoint(cx+allbarwidth+3*shift,cy);
		p.addPoint(cx+allbarwidth+4*shift,cy-shift);p.addPoint(cx+shift,cy-shift);
		g.setColor(backgraph_colorl); g.fillPolygon(p); g.setColor(Color.LIGHT_GRAY);
		g.drawPolygon(p);
		Polygon p2 = new Polygon();
		p2.addPoint(cx,cy);p2.addPoint(cx+shift,cy-shift);
		p2.addPoint(cx+shift,cy-shift-barsize);p2.addPoint(cx,cy-barsize);
		g.setColor(backgraph_colorh); g.fillPolygon(p2); g.setColor(Color.LIGHT_GRAY);
		g.drawPolygon(p2);
		Polygon p3 = new Polygon();
		p3.addPoint(cx+shift,cy-shift);p3.addPoint(cx+allbarwidth+4*shift,cy-shift);
		p3.addPoint(cx+allbarwidth+4*shift,cy-shift-barsize);p3.addPoint(cx+shift,cy-shift-barsize);
		g.setColor(backgraph_colorm); g.fillPolygon(p3); g.setColor(Color.LIGHT_GRAY);
		g.drawPolygon(p3);


		cx+=2*shift;
		
		// Loop on each block
        for (int j = 0; j < nbblocks; j++) {
            // Draw the block label
			//Trace.debug("Write block j="+j+" with cx="+cx,"");
            cy = getSize().height - metrics.getHeight() - metrics.getDescent();
            g.setColor(Color.black);
            String[] ss=blabels[j].split("§",0);
            for (int i=0; i<ss.length; i++) {
	            int cxoffset=((nbvalues*(valWidth+valSpacing))-metrics.stringWidth(ss[i]))>>1;
	            if (cxoffset<0) { cxoffset=0; }
	            g.drawString(ss[i], cx+cxoffset, cy);
				cy+=metrics.getHeight()-2;
			}

			// Loop on each value
	        for (int i = 0; i < nbvalues; i++) {
	
	            cy = getSize().height - metrics.getHeight() - metrics.getDescent() - 4;
	            cy -= metrics.getHeight() - 4;
	
	            // draw the shadow and bar
				draw3DBar(g,cx,cy,valWidth,values[j][i]*barsize/max[i],SHIFTBAR,colors[i]);

	            cy -= values[j][i] + 5;
	            cx += (valWidth + valSpacing);
			}

            cx += blockSpacing;
        }
    }    
    
    public synchronized String getAppletInfo() {
        return "Title: "+title+"\n";
    }
    
    public synchronized String[][] getParameterInfo() {
        String[][] info = {
            {"title", "string", "The title of bar graph.  Default is 'Chart'"},
            {"nbvalues", "int", "The number of nbvalues/rows.  Default is 5."},
            {"orientation", "{VERTICAL, HORIZONTAL}", "The orienation of the bar graph.  Default is VERTICAL."},
            {"c#", "int", "Subsitute a number for #.  " + "The value/size of bar #.  Default is 0."},
            {"c#_label", "string", "The label for bar #.  " + "Default is an empty label."},
            {"c#_style", "{SOLID, STRIPED}", "The style of bar #.  " + "Default is SOLID."},
            {"c#_color", "{RED, GREEN, BLUE, PINK, ORANGE, MAGENTA, CYAN, " + "WHITE, YELLOW, GRAY, DARKGRAY}", "The color of bar #.  Default is GRAY."}
        };
        return info;
    }
}



// # Applet Applet.getAppletContext().getApplet( "receiver" )
// that accesses another Applet uniquely identified via a name you assign in the HTML <applet name= tag.
// # Applet Enumeration Applet.getAppletContext().getApplets()
// that gets you a list of all the Applets, of any class, not just yours, running on the page (including yourself).

