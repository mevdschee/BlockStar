package
{
  import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import mx.controls.Text;
  import mx.controls.Button;
  import mx.controls.ProgressBar;
  import mx.containers.VBox;
  import mx.core.Application;
  import mx.events.FlexEvent;
  import com.gskinner.ui.DisplayObjectWrapper;

  public class BlockStarApplication extends Application
  {
    public var button:Button;
    public var gameBox:VBox;
    public var instructionBox:VBox;
    public var pointsText:Text;
    public var startButton:Button;
    public var timeBar:ProgressBar;
    public var game:BlockStar;
    
    private var timer:Timer;
	  private var level:int;
    private var seconds:int;
    private var score:int;
    private var stars:int;
    
    public function BlockStarApplication()
    { addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
    }

    protected function onCreationComplete(event:FlexEvent):void
    { button.addEventListener(MouseEvent.CLICK, onButtonClick);
      startButton.addEventListener(MouseEvent.CLICK, onStartButtonClick);
      timer = new Timer(1000);
      timer.addEventListener(TimerEvent.TIMER, onTimer);
      game.addEventListener(BlockStar.STAR, onStar);
      game.addEventListener(BlockStar.TIME, onTime);
      stop();
    }

    protected function onButtonClick(event:MouseEvent):void
    { game.addRow();
    }

    protected function onStartButtonClick(event:MouseEvent):void
    { start();
    }
    
    private function onTimer(event:TimerEvent):void
    { seconds--;
      if (seconds<0)
      { timer.stop();
        stop();
      }
      else
      { timeBar.setProgress(seconds,60);
        timeBar.label = seconds+' seconds';
      }  
    }
    
    private function onTime(event:Event):void
    { seconds+=31;
      if (seconds>61) seconds=61;
      onTimer(null);
    }
        
    private function onStar(event:Event):void
    { stars++;
      score++;
      if (stars==level)
      { nextLevel();
      }
      updatePoints(stars,level,score);
    }
    
    private function updatePoints(stars:int,level:int,score:int):void
    { pointsText.htmlText='<font size="+1">'+stars+'/'+level+'</font> stars<br><br><font size="+11">'+score+'</font> points';
    }
        
    private function stop():void
    { instructionBox.visible = true;
      gameBox.mouseChildren = false;
    }
    
    private function start():void
    { instructionBox.visible = false;
      gameBox.mouseChildren = true;
      score=0;
      level=0;
      seconds=45;
      nextLevel();
      timer.start();
    }
    
    private function nextLevel():void
    { level++;
      stars=0;
      seconds+=16;
      if (seconds>61) seconds=61;
      onTimer(null);
      game.initLevel(level);
      updatePoints(stars,level,score);
    }
    
  }
}
