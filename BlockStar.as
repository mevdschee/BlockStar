package
{
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.utils.getTimer;
  import com.gskinner.motion.GTween;
	import mx.effects.easing.Bounce;

	public class BlockStar extends MovieClip
	{		
	  public static const STAR:String = "star";
    public static const TIME:String = "time";
    
    private var blocks:Array;
	  private var timer:Timer;
	  private var drag:Sprite;
    private var draggedBlocks:Array;
    private var background:Sprite;
    private var clipMask:Sprite;
      
	  private static const X:int = 0;
		private static const Y:int = 0;
	  private static const WIDTH:int = 6;
		private static const HEIGHT:int = 15;
    private static const EXPLODE_COUNT:int = 5;
    private static const INIT_ROWS:int = 5;
    private static const COLORS:Array = [0xFF0000,0x00FF00,0x0000FF,0xFFFF00,0x00FFFF,0xFF00FF];
    
   	public function BlockStar()
		{ init();
		}

    private function random(max:int):int
    { return Math.floor(Math.random()*max);
    }
    
    private function init():void
    { background = new Sprite();
      background.graphics.beginFill(0xDFDFDF,5);
      background.graphics.drawRect(0, 0, WIDTH*Block.WIDTH, HEIGHT*Block.HEIGHT);
      background.graphics.endFill();
      addChild(background);
    
      addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		  addEventListener(MouseEvent.ROLL_OUT,onMouseUp);
		  
		  timer = new Timer(100);
      timer.addEventListener(TimerEvent.TIMER, onTimer);
      draggedBlocks = new Array();
      drag = new Sprite();
      addChild(drag);
      drag.startDrag();
      
      clipMask = new Sprite();
      clipMask.graphics.beginFill(0x000000);
      clipMask.graphics.drawRect(0, 0, width, height);
      clipMask.graphics.endFill();
      addChild(clipMask);
      mask = clipMask;
    }
    
    public function initLevel(stars:int):void
    { var isStar:Array = new Array();
		  for (var x:int=0;x<WIDTH;x++)
		  { isStar[x] = new Array();
		    for (var y:int=0;y<INIT_ROWS;y++)
		    { isStar[x][y]=false;
		    }
		  }
      while (stars>0)
      { x = random(WIDTH);
        y = random(INIT_ROWS);
        if (!isStar[x][y])
        { isStar[x][y] = true;
          stars--;
        }
      }
      if (blocks) for (x=0;x<WIDTH;x++)
		  { if (blocks[x]) for (y=0;y<blocks[x].length;y++)
		    { if(blocks[x][y]) removeChild(blocks[x][y]);
		    }
		  }
      blocks = new Array();
		  for (x=0;x<WIDTH;x++)
		  { blocks[x] = new Array();
		    for (y=0;y<INIT_ROWS;y++)
		    { initBlock(x,y+HEIGHT,COLORS[random(COLORS.length)],isStar[x][y],false);
		    }
		  }
		  timer.start();
    }
    
    private function initBlock(x:int,y:int,color:int,star:Boolean,time:Boolean):void
    { blocks[x][y] = new Block(color,star,time);
      var c:Object = blockCoordinatesToCoordinates(x,y);
		  blocks[x][y].x = c.x;
		  blocks[x][y].y = c.y;
		  blocks[x][y].buttonMode = true;
		  blocks[x][y].addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		  blocks[x][y].addEventListener(Block.EXPLODE, removeExploded);
		  addChild(blocks[x][y]);
    }

    private function blockToCoordinates(block:Block):Object
    { for (var x:int=0;x<WIDTH;x++)
		  { for (var y:int=0;y<blocks[x].length;y++)
		    { if (blocks[x][y]==block) return {x:x,y:y};
		    }
		  }
		  return {x:-1,y:-1};
	  }
	  
    private function blockCoordinatesToCoordinates(x:int,y:int):Object
    { return {x:X+x*Block.WIDTH,y:Y+(HEIGHT-1-y)*Block.HEIGHT};
	  }
	  
    private function coordinatesToBlockCoordinates(x:int,y:int):Object
    { return {x:(x-X)/Block.WIDTH,y:HEIGHT-1-(y-Y)/Block.HEIGHT};
	  }

    public function addRow():void
    { for (var x:int=0;x<WIDTH;x++)
		  { for (var y:int=blocks[x].length;y>=HEIGHT-1;y--)
		    { if (blocks[x][y] && y>=HEIGHT-1) return;
		    }
      }
      for (x=0;x<WIDTH;x++)
		  { for (y=blocks[x].length;y>=0;y--)
		    { if (y==0)
		      { initBlock(x,y,COLORS[random(COLORS.length)],false,random(WIDTH*HEIGHT)==0);
		        blocks[x][y].y+=Block.HEIGHT;
  	      }
		      if (blocks[x][y-1])
		      { blocks[x][y] = blocks[x][y-1];
		        blocks[x][y-1] = null;
		      }
		      var c:Object = blockCoordinatesToCoordinates(x,y);
          if (blocks[x][y]!=null) new GTween(blocks[x][y], 0.5, {y:c.y}, {ease:Bounce.easeOut});
		    }
      }
    }
    
    public function onMouseUp(event:MouseEvent):void
    { var dx:int = Math.round(drag.x / Block.WIDTH);
      for each (var block:Block in draggedBlocks)
      { var c:Object = coordinatesToBlockCoordinates(block.x,block.y);
        //var x:int = c.x+dx;
        var x:int = c.x;
        if (x<0) x=0;
        if (x>=WIDTH) x=WIDTH-1;
        var y:int = findTopEmptyBlock(x)+1;
        drag.removeChild(block);
        initBlock(x,y,block.color,block.star,block.time);
      }
      //bring to front
      setChildIndex(drag,numChildren-1);
      draggedBlocks = new Array();
    }
    
    public function onMouseDown(event:MouseEvent):void
    { 
      var block:Block = Block(event.target.parent is Block?event.target.parent:event.target.parent.parent);
      var coords:Object = blockToCoordinates(block);
      var x:int = coords.x;
      var y:int = coords.y;
      
      if (x<0 || y<0 || blocks[x][y]==null) return;
      if (blocks[x][y].exploding || blocks[x][y].star || blocks[x][y].time) return;
      if (draggedBlocks.length>0) return;
      
      drag.x = 0;
      drag.y = 0;
      
      initSearch();
      var coordinates:Array = floodSearch(x,y,blocks[x][y].color);
      for each (var c:Object in coordinates)
      { if (!blocks[c.x][c.y].star && !blocks[c.x][c.y].time)
        { var draggedBlock:Block = blocks[c.x][c.y];
          draggedBlocks.push(draggedBlock);
          removeChild(draggedBlock);
          drag.addChild(draggedBlock);
          blocks[c.x][c.y] = null;
        }
      }
    }
    
    private function findTopEmptyBlock(x:int):int
    { for (var y:int=blocks[x].length-1;y>=0;y--)
		  { if (blocks[x][y]!=null) return y+1;
	    }
	    return 0;
    }

    private function onTimer(event:TimerEvent):void
    { fallBlocks();
      explodeBlocks();
      fallBlocks();
    }
		
		private function removeExploded(event: Event):void
	  { var coords:Object = blockToCoordinates(Block(event.target));
      var x:int = coords.x;
      var y:int = coords.y;
	    if (x<0 || y<0 || blocks[x][y]==null) return;
      if (!blocks[x][y].exploding) return;
      
	    var star:Boolean = blocks[x][y].star;
      var time:Boolean = blocks[x][y].time;
      removeChild(blocks[x][y]);
      blocks[x][y] = null;
      if (star) dispatchEvent(new Event(STAR));
      if (time) dispatchEvent(new Event(TIME));
	  }
	  
    private function initSearch():void
	  { for (var x:int=0;x<WIDTH;x++)
		  { for (var y:int=0;y<blocks[x].length;y++)
		    { if (blocks[x][y]) blocks[x][y].seen = false;
		    }
		  }
		}
		
		private function explodeBlocks():void
	  { initSearch();
	    for (var x:int=0;x<WIDTH;x++)
		  { for (var y:int=0;y<blocks[x].length;y++)
		    { if (blocks[x][y] && !blocks[x][y].seen && !blocks[x][y].exploding)
		      { var coordinates:Array = floodSearch(x,y,blocks[x][y].color);
		        var explodingBlocks:Array = new Array();
		        for each (var c:Object in coordinates)
            { explodingBlocks.push(blocks[c.x][c.y]);
		        }
		        if (explodingBlocks.length >= EXPLODE_COUNT)
		        { var explodeTime:Number = getTimer();
		          for each (var block:Block in explodingBlocks)
		          { block.explode(explodingBlocks,explodeTime);
		          }
            }
		      }  
		    }
		  }
	  }
	  
		private function floodSearch(x:int,y:int,color:int):Array
	  { var explode_blocks:Array = new Array({x:x,y:y});
	    blocks[x][y].seen = true;
	    var moves:Array = new Array({x:-1,y:0},{x:1,y:0},{x:0,y:1},{x:0,y:-1});
	    for each (var move:Object in moves)
	    { var mx:int = x+move.x;
	      var my:int = y+move.y;
	      if (mx>=0 && mx<WIDTH && my>=0 && my<blocks[mx].length && blocks[mx][my] && blocks[mx][my].color == color && !blocks[mx][my].seen)
	      { explode_blocks = explode_blocks.concat(floodSearch(mx,my,color));
	      }
	    }
	    return explode_blocks;
	  }
	  
	  private function fallBlock(x:int,y:int,fall:int):void
	  { var block:Block = blocks[x][y];
	    var x2:int = x;
	    var y2:int = y-fall;
	    var c:Object = blockCoordinatesToCoordinates(x2,y2);
	    new GTween(block, 0.5, {y:c.y}, {ease:Bounce.easeOut});
	    blocks[x][y] = null;
	    blocks[x2][y2] = block;
	  }
	  
		private function fallBlocks():void
	  { for (var x:int=0;x<WIDTH;x++)
		  { var fall:int = 0;
		    for (var y:int=0;y<blocks[x].length;y++)
		    { if (blocks[x][y])
		      { if (fall>0) fallBlock(x,y,fall);
		      }
		      else fall++;
		    }
		  }
	  }
	  
	}
	
}
