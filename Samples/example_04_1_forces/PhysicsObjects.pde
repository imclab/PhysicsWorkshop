//
// Physics Objects
//

// This is our simulation object
// It's created here so we don't need to worry about it elsewhere
SimpleSimulation simulation = new SimpleSimulation();

class SimpleSimulation
{
  ArrayList<Node> nodes;
  ArrayList<Node> pinned_nodes;
  ArrayList<Spring> springs;

  SimpleSimulation()
  {
    nodes = new ArrayList<Node>();
    pinned_nodes = new ArrayList<Node>();
    springs = new ArrayList<Spring>();
  }
  
  Node createNode( float _x, float _y )
  {
    Node n = new Node( _x, _y );
    nodes.add( n );
    return n;
  }

  Spring createSpring( Node _a, Node _b, float _stiffness )
  {
    Spring spring = new Spring( _a, _b, _stiffness );
    springs.add( spring );
    return spring;
  }
  
  void clear()
  {
    nodes.clear();
    pinned_nodes.clear();
    springs.clear();
  }
  
  void pinNode( Node node )
  {
    pinned_nodes.add( node );
  }

  void update()
  {
    for ( Spring s : springs )
    { // update every Spring in our collection named springs
      s.update();
    }

    for( Node n : pinned_nodes )
    { // snap pinned node back into place
      n.x = n.px;
      n.y = n.py;
    }

    for ( Node n : nodes )
    { // update every Node in our collection named nodes
      n.update();
    }
  }

  // wraps all nodes to screen
  // will cause crazy behavior with springs if only one node wraps
  void wrapNodesToScreen()
  {
    for ( Node n : nodes )
    {
      if ( n.x > width )
      {
        n.x -= width;
        n.px -= width;
      }
      else if ( n.x < 0 )
      {
        n.x += width;
        n.px += width;
      }
      if ( n.y > height )
      {
        n.y -= height;
        n.py -= height;
      }
      else if ( n.y < 0 )
      {
        n.y += height;
        n.py += height;
      }
    }
  }

  // constrains all nodes to screen
  void constrainNodesToScreen()
  {
    for ( Node n : nodes )
    {
      if ( n.x > width )
      {
        float dx = n.x - n.px;
        n.x = width;
        n.px = width + dx;  // flip direction of travel to bounce
      }
      else if ( n.x < 0 )
      {
        float dx = n.x - n.px;
        n.x = 0;
        n.px = dx;
      }
      if ( n.y > height )
      {
        float dy = n.y - n.py;
        n.y = height;
        n.py = height + dy;
      }
      else if ( n.y < 0 )
      {
        float dy = n.y - n.py;
        n.y = 0;
        n.py = dy;
      }
    }
  }

  // Separate nodes to minimum distance, with some stiffness
  void separateNodes( float minDist, float stiffness )
  {
    float minDist2 = minDist * minDist;
    for ( int i = nodes.size() - 1; i > 0; --i )
    {
      Node n1 = nodes.get(i);
      for ( int j = i - 1; j >= 0; --j )
      {
        Node n2 = nodes.get(j);
        float dx = n2.x - n1.x;
        float dy = n2.y - n1.y;
        float dist2 = dx * dx + dy * dy;
        if ( dist2 < minDist2 )
        { // too close
          float angle = atan2( dy, dx );
          float tx = n1.x + cos( angle ) * minDist;
          float ty = n1.y + sin( angle ) * minDist;
          // move apart
          float p1 = 0.5;
          float p2 = 0.5;
          float ax = (tx - n2.x) * stiffness;
          float ay = (ty - n2.y) * stiffness;
          n1.x += -ax * p1;
          n1.y += -ay * p1;
          n2.x += ax * p2;
          n2.y += ay * p2;
        }
      }
    }
  }

  // draw all springs as lines
  void drawSprings()
  {
    for ( Spring s : springs )
    {
      line( s.a.x, s.a.y, s.b.x, s.b.y );
    }
  }

  // draw all nodes as ellipses
  void drawNodes()
  {
    for ( Node n : nodes )
    {
      ellipse( n.x, n.y, 8, 8 );
    }
  }
}
// Node performs verlet integration
class Node
{
  float x, y;
  float px, py;
  float damping = 0.95;
  Node( float _x, float _y )
  {
    x = _x;
    y = _y;
    px = x;
    py = y;
  }

  void update()
  {
    float vx = x - px;
    float vy = y - py;
    float cx = x;
    float cy = y;
    x = x + vx * damping;
    y = y + vy * damping;
    px = cx;
    py = cy;
  }

  void setPosition( float x, float y )
  {
    this.x = this.px = x;
    this.y = this.py = y;
  }
}

// Spring connects two nodes with variable stiffness
class Spring
{
  float rest_length;
  float stiffness;
  Node a, b;
  Spring( Node _a, Node _b, float _rest_length, float _stiffness )
  {
    a = _a;
    b = _b;
    rest_length = _rest_length;
    stiffness = _stiffness;
  }

  Spring( Node _a, Node _b, float _stiffness )
  {
    a = _a;
    b = _b;
    rest_length = dist( a.x, a.y, b.x, b.y );
    stiffness = _stiffness;
  }

  void update()
  {
    float dx = b.x - a.x;
    float dy = b.y - a.y;
    float distance = sqrt( dx * dx + dy * dy );
    float delta = rest_length - distance;
    float offsetX = (delta * dx / distance) / 2 * stiffness;
    float offsetY = (delta * dy / distance) / 2 * stiffness;
    a.x -= offsetX;
    a.y -= offsetY;
    b.x += offsetX;
    b.y += offsetY;
  }
}

