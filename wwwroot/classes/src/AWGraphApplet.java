/*
 * @(#)AWGraphApplet.java
 *
 */

import java.applet.Applet;
import java.awt.*;
import java.util.Vector;


public class AWGraphApplet extends Applet
{
	
    public AWGraphApplet()
    {
        special = "Not yet defined";
        textVertSpacing = 0;
        b_fontsize = 11;
        blockSpacing = 5;
        valSpacing = 0;
        valWidth = 5;
        maxLabelWidth = 0;
        background_color = Color.white;
        border_color = Color.white;
        special_color = Color.gray;
        backgraph_colorl = Color.decode("#F6F6F6");
        backgraph_colorm = Color.decode("#EDEDED");
        backgraph_colorh = Color.decode("#E0E0E0");
    }

//    public synchronized void init() {
    public synchronized void start()
    {
        special = getParameter("special");
        if (special == null) { special = ""; }

        Log("Applet "+VERSION+" init");

        String s = getParameter("b_fontsize");
        if (s != null) { b_fontsize = Integer.parseInt(s); }

        title = getParameter("title");
        if (title == null) { title = "Chart"; }

        s = getParameter("nbblocks");
        if (s != null) { nbblocks = Integer.parseInt(s); }

        s = getParameter("nbvalues");
        if (s != null) { nbvalues = Integer.parseInt(s); }

        s = getParameter("blockspacing");
        if (s != null) { blockSpacing = Integer.parseInt(s); }
        s = getParameter("valspacing");
        if (s != null) { valSpacing = Integer.parseInt(s); }
        s = getParameter("valwidth");
        if (s != null) { valWidth = Integer.parseInt(s); }

        s = getParameter("orientation");
        if (s == null) { orientation = VERTICAL; }
        else if (s.equalsIgnoreCase("horizontal")) { orientation = HORIZONTAL; }
        else { orientation = VERTICAL; }
        s = getParameter("barsize");
        if (s != null) { barsize = Integer.parseInt(s); }

		s = getParameter("background_color");
        if (s != null) { background_color = Color.decode("#"+s); }
		s = getParameter("border_color");
        if (s != null) { border_color = Color.decode("#"+s); }
		s = getParameter("special_color");
        if (s != null) { special_color = Color.decode("#"+s); }

        Log("bblocks "+nbblocks);
        Log("nbvalues "+nbvalues);
        Log("barsize "+barsize);
        
		font  = new Font("Verdana,Arial,Helvetica", 0, b_fontsize);
		fontb = new Font("Verdana,Arial,Helvetica", Font.BOLD, b_fontsize);
        fontmetrics = getFontMetrics(font);
        
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
			if (max[i]<=0.0F) { max[i]=1.0F; }
			Log("max["+i+"]="+max[i]);
		}
    }
            
	private synchronized void Log(String s)
	{
		System.out.println(getClass().getName()+" ("+special+"): "+s);
	}
		
    private synchronized void parsebLabel(int i)
    {
        String s = getParameter("b" + (i+1) + "_label");
        if (s==null) {
            blabels[i] = "";
        } else {
            blabels[i] = s;
        }
        maxLabelWidth = Math.max(fontmetrics.stringWidth(blabels[i]), maxLabelWidth);
    }

    private synchronized void parseLabel(int i)
    {
        String s = getParameter("v" + (i+1) + "_label");
        if (s==null) {
            vlabels[i] = "";
        } else {
            vlabels[i] = s;
        }
    }

    private synchronized void parseStyle(int i)
    {
        String s = getParameter("v" + (i+1) + "_style");
        if (s == null || s.equalsIgnoreCase("solid")) {
            styles[i] = SOLID;
        } else if (s.equalsIgnoreCase("striped")) {
            styles[i] = STRIPED;
        } else {
            styles[i] = SOLID;
        }
    }
    
    private synchronized void parseColor(int i)
    {
        String s = getParameter("v" + (i+1) + "_color");
        if (s != null) {
            colors[i] = Color.decode("#"+s);
        } else {
            colors[i] = Color.gray;
        }
    }

    private synchronized void parseMax(int i)
    {
        String s = getParameter("v" + (i+1) + "_max");
        if (s != null) {
			max[i] = Float.valueOf(s).floatValue();
        } else {
            max[i] = 1.0F;
        }
    }

    private synchronized void parseValue(int i)
    {
        String s = getParameter("b" + (i+1));
		if (s != null) {
        	String[] as=split(s," ",0);
        	for (int j=0; j<as.length; j++) {
//				Log("as="+as[j]);
	            if (as[j].compareTo("?")==0) { values[i][j] = 0; }
	            else { values[i][j] = Float.parseFloat(as[j]); }
//				Log("values["+i+"]["+j+"]="+values[i][j]);
			}
	    }
    }

	private String[] split(String s, String c, int iStart)
	{
		Vector v = new Vector();
		boolean bFin = false;
		String sub = "";
		int i=iStart-1;
		int iOld = i;
		//System.out.println("s = " + s);
		while (!bFin) {
			iOld = i;
			i = s.indexOf(c, iOld+1);
			if (i!=-1) {
				//System.out.println("i = " + i);
				sub = s.substring(iOld+1, i);
			} else {
				sub = s.substring(iOld+1, s.length());
				bFin=true;
			}
			//System.out.println("sub = " + sub);
			v.addElement(sub);
		}
		String[] tabS = new String[v.size()];
		for (i=0 ; i<v.size() ; i++) {
			tabS[i] = (String)v.elementAt(i);
		}
		return tabS;
	}

	private String remove(String s, String c)
	{
		Vector v = new Vector();
		boolean bFin = false;
		String sub = "";
		int i=-1;
		int iOld = i;
		//System.out.println("s = " + s);
		while (!bFin) {
			iOld = i;
			i = s.indexOf(c, iOld+1);
			if (i!=-1) {
				//System.out.println("i = " + i);
				sub = s.substring(iOld+1, i);
			} else {
				sub = s.substring(iOld+1, s.length());
				bFin=true;
			}
			//System.out.println("sub = " + sub);
			v.addElement(sub);
		}
		sub = "";
		for (i=0 ; i<v.size() ; i++) {
			sub += (String)v.elementAt(i);
		}
		return sub;
	}

	private Graphics bfr;
	private Image img;

	public void init()
	{
		img = createImage(this.getSize().width, this.getSize().height);
		bfr = img.getGraphics();
	}

    public synchronized void paint(Graphics g)
    {
		// background and border
        bfr.setColor(background_color);
        bfr.fillRect(0, 0, getSize().width, getSize().height);
        bfr.setColor(border_color);
        bfr.drawRect(0, 0, getSize().width, getSize().height);

		// draw the bars and their titles
		if(orientation == HORIZONTAL) { paintHorizontal(bfr); }
		else { paintVertical(bfr); }

		g.drawImage(this.img, 0, 0, this);
    }
        
	private synchronized void draw3DBar(Graphics g,int x, int y, float w, float h, int shift, Color color)
	{
		// Draw a 3D bar at pos (x,y)
		Polygon polygon = new Polygon();
		int width=new Float(w).intValue();
		int height=new Float(h).intValue();
//		Log("draw3DBar "+x+","+y+","+w+"=>"+width+","+h+"=>"+height);

		polygon.addPoint(x,y);
		polygon.addPoint(x+width,y);
		polygon.addPoint(x+width,y-height);
		polygon.addPoint(x,y-height);
		g.setColor(color);
		g.fillPolygon(polygon);
		g.setColor(color.darker());
		g.drawPolygon(polygon);
		Polygon polygon2 = new Polygon();
		polygon2.addPoint(x+width,y);
		polygon2.addPoint(x+width+shift,y-shift);
		polygon2.addPoint(x+width+shift,y-shift-height);
		polygon2.addPoint(x+width,y-height);
		g.setColor(color.darker());
		g.fillPolygon(polygon2);
		g.setColor(color.darker().darker());
		g.drawPolygon(polygon2);
		Polygon polygon3 = new Polygon();
		polygon3.addPoint(x,y-height);
		polygon3.addPoint(x+width,y-height);
		polygon3.addPoint(x+width+shift,y-height-shift);
		polygon3.addPoint(x+shift,y-height-shift);
		g.setColor(color);
		g.fillPolygon(polygon3);
		g.setColor(color.darker());
		g.drawPolygon(polygon3);
 	}

    private synchronized void paintHorizontal(Graphics g)
    {
    }

    private synchronized void paintVertical(Graphics g)
    {
		g.setColor(Color.black);
		g.setFont(font);

		int shift=10;
		int allbarwidth=(((nbvalues*(valWidth+valSpacing))+blockSpacing)*nbblocks);
		int allbarheight=barsize;
		int axepointx=(getSize().width-allbarwidth)/2 - 2*shift;
        int axepointy = getSize().height - (2*fontmetrics.getHeight()) - 2 - textVertSpacing;

		int cx=axepointx;
		int cy=axepointy;

		// Draw axes
		Polygon polygon = new Polygon();
		polygon.addPoint(cx,cy);
		polygon.addPoint(cx+allbarwidth+3*shift,cy);
		polygon.addPoint(cx+allbarwidth+4*shift,cy-shift);
		polygon.addPoint(cx+shift,cy-shift);
		g.setColor(backgraph_colorl);
		g.fillPolygon(polygon);
		g.setColor(Color.lightGray);
		g.drawPolygon(polygon);
		Polygon polygon2 = new Polygon();
		polygon2.addPoint(cx,cy);
		polygon2.addPoint(cx+shift,cy-shift);
		polygon2.addPoint(cx+shift,cy-shift-barsize);
		polygon2.addPoint(cx,cy-barsize);
		g.setColor(backgraph_colorh);
		g.fillPolygon(polygon2);
		g.setColor(Color.lightGray);
		g.drawPolygon(polygon2);
		Polygon polygon3 = new Polygon();
		polygon3.addPoint(cx+shift,cy-shift);
		polygon3.addPoint(cx+allbarwidth+4*shift,cy-shift);
		polygon3.addPoint(cx+allbarwidth+4*shift,cy-shift-barsize);
		polygon3.addPoint(cx+shift,cy-shift-barsize);
		g.setColor(backgraph_colorm);
		g.fillPolygon(polygon3);
		g.setColor(Color.lightGray);
		g.drawPolygon(polygon3);

		cx+=2*shift;
		
		// Loop on each block
        for (int j = 0; j < nbblocks; j++) {

            // Draw the block label
//			Log("Write block j="+j+" with cx="+cx);
            cy = getSize().height - fontmetrics.getHeight() - 3 - textVertSpacing;
            g.setColor(Color.black);

			// Check if bold or highlight
			int bold=0; int highlight=0; String label=blabels[j];
			if (blabels[j].indexOf(":")>0) { bold=1; label=remove(blabels[j],":"); }
			if (blabels[j].indexOf("!")>0) { highlight=1; label=remove(blabels[j],"!"); }

			if (bold==1) { g.setFont(fontb); }
			String as[] = split(label, "\247", 0);
			// Write background for block legend
			if (highlight==1) {
				g.setColor(special_color);
				g.fillRect(cx-Math.max(-1+blockSpacing>>1,0),cy-fontmetrics.getHeight()+2,(nbvalues*(valWidth+valSpacing))+Math.max(blockSpacing-2,0)+1,((fontmetrics.getHeight()+textVertSpacing)*as.length)+2);
				g.setColor(Color.black);
			}
			// Write text for block legend
            for (int i=0; i<as.length; i++) {
				int cxoffset=((nbvalues*(valWidth+valSpacing))-fontmetrics.stringWidth(as[i]))>>1;
	            if (cxoffset<0) { cxoffset=0; }
				g.drawString(as[i], cx+cxoffset, cy);
				cy+=fontmetrics.getHeight()+textVertSpacing-1;
			}
			if (bold==1) { g.setFont(font); }

			// Loop on each value
	        for (int i = 0; i < nbvalues; i++) {
	
	            cy = getSize().height - fontmetrics.getHeight() - 6 - textVertSpacing;
	            cy -= fontmetrics.getHeight() - 4;
	
	            // draw the shadow and bar
				draw3DBar(g,cx,cy,valWidth,(values[j][i]*(float)barsize)/max[i],SHIFTBAR,colors[i]);

       			cy = (int)((float)cy - (values[j][i] + 5F));
	            cx += (valWidth + valSpacing);
			}

            cx += blockSpacing;
        }
    }    
    
    public synchronized String getAppletInfo()
    {
        return "Title: " + title + "\n";
    }
    
    public synchronized String[][] getParameterInfo()
    {
        String[][] as = {
            {"version", "string", "AWGraphApplet "+VERSION},
            {"copyright", "string", "GPL"},
            {"title", "string", title}
        };
        return as;
    }

    private static final int VERTICAL = 0;
    private static final int HORIZONTAL = 1;
    private static final int SOLID = 0;
    private static final int STRIPED = 1;
	private static final int DEBUG = 3;
	private static final int SHIFTBAR = 3;
	private static final String VERSION = "1.1";

    private String title;
    private String special;
    private Font font;
    private Font fontb;
    private FontMetrics fontmetrics;
    private int orientation;
    private int barsize;

    private int nbblocks;
    private String blabels[];
	private int b_fontsize;
    private int blockSpacing;
    private int textVertSpacing;
	
    private int nbvalues;
    private Color colors[];
    private String vlabels[];
    private int styles[];
    private float max[];
    private int valSpacing;
    private int valWidth;

    private float values[][];

    private int maxLabelWidth;
	private Color background_color;
	private Color border_color;
	private Color special_color;
	private Color backgraph_colorl;
	private Color backgraph_colorm;
	private Color backgraph_colorh;
}



// # Applet Applet.getAppletContext().getApplet( "receiver" )
// that accesses another Applet uniquely identified via a name you assign in the HTML <applet name= tag.
// # Applet Enumeration Applet.getAppletContext().getApplets()
// that gets you a list of all the Applets, of any class, not just yours, running on the page (including yourself).

