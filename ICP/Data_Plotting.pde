/*
  No much effort while reproducing Matplotlib from Python.
  Just enough so data being used could be barely visualized
*/


final Float MAX = Float.MAX_VALUE;
final float MIN = -Float.MAX_VALUE;


Subplot plot_data( PVector[] data_1, PVector[] data_2, String label_1, String label_2 ) {
  return plot_data( data_1, data_2, label_1, label_2, 8, 8);
}

Subplot plot_data( PVector[] data_1, PVector[] data_2, String label_1, String label_2, int markersize_1, int markersize_2) {
  Subplot ax = plt.figure(100, 60).add_subplot();
  if (data_1 != null)   ax.plot(data_1, #336699, markersize_1, label_1);
  if (data_2 != null)   ax.plot(data_2, #ff3300, markersize_1, label_2);
  ax.legend();
  return ax;
}


class Plot {
  Figure fig;

  Figure figure( int w, int h ) {
    this.fig = new Figure(w, h);
    return fig;
  }
  void show() {
    image( fig.g, 0, 0 );
    for (Subplot s : fig.subplotls) {
      s.offx = fig.padding + width/2 - int(s.dataArea.w/2);
      s.offy = height/2 - fig.padding + int(s.dataArea.h/2);
      
      for (PGraphics p : s.plotls ) {
        Tuple orig = s.origls.get(s.plotls.indexOf(p));
        image( p, (int)orig.x + s.offx , s.offy - (int)orig.y );
      }
      
      stroke(100);
      rect(s.offx-1,s.offy-1,2,2);
      line(0,s.offy,width,s.offy);
      line(s.offx,0,s.offx,height);

    }
  }
}


class Figure {
  PGraphics g;
  float scale = 5.;
  int padding = 30;
  ArrayList<Subplot> subplotls = new ArrayList();
  

  Figure( int w, int h ) {
    g = createGraphics(width, height);
    g.beginDraw();
    g.background(-1);
    g.fill(-1);
    g.stroke(0);
    g.strokeWeight(1);
    g.rect(padding, 2, width-padding-2, height-padding-2);
    g.endDraw();
  }

  Subplot add_subplot() {
    subplotls.add(new Subplot(this));
    return subplotls.get(subplotls.size()-1);
  }
}


class Legend {
  String label;
  int fill;
  Legend( String label, int fill) {
    this.label = label;
    this.fill = fill;
  }
}

class BBox {
  float x, y, w, h;
  BBox(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
}

class Subplot {
  final int EQUAL = 0;
  int negative = 1000;
  int axis = EQUAL;
  int fill = 0;
  int scale = 10;
  int offx = 0;
  int offy = 0;
  BBox dataArea = new BBox(MAX, MAX, MIN, MIN);

  ArrayList<Legend> legend= new ArrayList();
  float legendMax = 50;
  ArrayList<PGraphics> plotls = new ArrayList();
  ArrayList<Tuple<Integer,Integer>>origls = new ArrayList();
  PGraphics result;
  Figure fig;

  Subplot(Figure fig) {
    this.fig = fig;
  }



  void plot(PVector[] data, int fill, int markersize, String label) {

    PGraphics plot;
    int shiftx = 0;
    int shifty = 0;

    this.fill = fill;
    int mk = markersize/2;
    float lxMin = MAX, lyMin = MAX, lxMax = MIN, lyMax = MIN;

    legendMax = max( textWidth(label), legendMax );
    if (label != "") legend.add( new Legend( label, fill ));

    for (int i= 0; i < data.length; i++) {
      float dx =  data[i].x * scale;
      float dy =  data[i].y * scale;
      lxMin = min ( lxMin, dx );
      lyMin = min ( lyMin, dy );
      lxMax = max ( lxMax, dx );
      lyMax = max ( lyMax, dy );
    }

    shiftx = (int) -lxMin + mk;
    shifty = (int) (lyMax + mk );
    origls.add(new Tuple( (int)lxMin, (int)lyMax ) );
    plot = createGraphics( (int) (lxMax - lxMin + mk*2), (int)(lyMax - lyMin + mk*2) );
    plot.beginDraw();
    //plot.fill(50,50); //debug data area
    //plot.rect(0, 0, (int) (lxMax - lxMin + mk*2), (int)(lyMax - lyMin + mk*2));//debug data area
    
    
    for (int i= 0; i < data.length; i++) {
      float dx =  shiftx + data[i].x * scale;
      float dy =  shifty + data[i].y * -scale;
      plot.stroke(fill);
      plot.strokeWeight(markersize);
      plot.point( dx, dy );
      //line
      if (i < data.length-1) {
        plot.strokeWeight(1);
        plot.line( dx, dy, shiftx + data[i+1].x * scale, shifty + data[i+1].y * -scale);
      }
    }
    
    plot.endDraw();
    plotls.add(plot);
    
    dataArea.x = min(lxMin, dataArea.x);
    dataArea.y = min(lyMin, dataArea.y);
    dataArea.w = max(lxMax, dataArea.w);
    dataArea.h = max(lyMax, dataArea.h);
    

  }

  void legend() {
    int margin = 5;
    int line = 15;
    fig.g.beginDraw();
    fig.g.stroke(0);
    fig.g.strokeWeight(1);
    int lw = (int)legendMax+margin*3;
    int lh = margin + legend.size() * line;
    int x = fig.g.width - lw - margin;
    int y = margin;
    fig.g.fill(-1);
    fig.g.rect( x, y, lw - margin, lh);
    for (int i = 0; i < legend.size(); i++) {
      Legend l = legend.get(i);
      fig.g.fill(l.fill);
      fig.g.text(l.label, x+margin, margin + line + i * line );
    }


    fig.g.endDraw();
  }
}
