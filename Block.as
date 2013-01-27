package
{
  import flash.display.Sprite;
  import flash.utils.Timer;
	import flash.events.Event;
  import flash.geom.ColorTransform;
  import com.gskinner.motion.GTween;
  import BlockSprite;
  import StarSprite;
  import TimeSprite;
	
  public class Block extends Sprite
  { 
    public static const WIDTH:int = 20;
    public static const HEIGHT:int = 20;
    public static const EXPLODE:String = "explode";

    public var color:int;
		public var star:Boolean;
		public var time:Boolean;
		public var explodeTime:Number;
		
		// helper variable should be gone
		public var seen:Boolean;
		
		public var exploding:Boolean;
		
    private var blockSprite:BlockSprite = new BlockSprite(); 
    
    private var starSprite:StarSprite = new StarSprite();
		
    private var timeSprite:TimeSprite = new TimeSprite(); 
		
		public function Block(color:int,star:Boolean,time:Boolean):void
    { this.color = color;
      this.star = star;
      this.time = time;
      var tf:ColorTransform = blockSprite.transform.colorTransform;  
      tf.color = color;  
      blockSprite.transform.colorTransform = tf; 
      addChild(blockSprite);
      if (star) addChild(starSprite);
      if (time) addChild(timeSprite);
    }
    
    public function explode(explodingBlocks:Array,explodeTime:Number):void
    {	if (!exploding)
      { exploding = true;
        this.explodeTime = explodeTime;
        var firstExplodeTime:Number = explodeTime;
        for each (var block:Block in explodingBlocks)
        { if (block.exploding && block.explodeTime<firstExplodeTime)
          { firstExplodeTime = block.explodeTime;
          }
        }
        var t:GTween = new GTween(this,1,{alpha:0},{ease:GoBackGoBackGo,completeListener:onExplodeComplete});
        t.position = (explodeTime-firstExplodeTime)/1000.0;
      }
    }
    
    private static function GoBackGoBackGo(time:Number, begin:Number, change:Number, duration:Number):Number
    { return begin+(Math.cos(time/duration * 2.5 * Math.PI * 2 + Math.PI) + 1)/2*change;
    }
    
    private function onExplodeComplete(event:Event):void
    { dispatchEvent(new Event(EXPLODE));
    }
    
  }
}
