import flash.external.ExternalInterface;

import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.Event;

import flash.display.StageScaleMode;
import flash.display.StageAlign;

import flash.text.StyleSheet;
import flash.text.TextField;

import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.net.URLRequest;
import flash.display.Loader;


class LearnFlash extends Sprite {
    public var stf:StyledTextField;
    public var cc:ColorChanger;

    static function main(){
        // trace() goes to firebug. turn on/off with compilation flag.
        // only works with http: url, not a file:/// url.
        haxe.Firebug.redirectTraces();


        // flc.stage in haxe is like stage in as3;
        var flc = flash.Lib.current;
        flc.stage.scaleMode = StageScaleMode.NO_SCALE;
        flc.stage.align     = StageAlign.TOP_LEFT;
        
        flc.addChild(new LearnFlash());
    }

    public function new(){
        super();
        
        // this line is needed for keyboard events.
        // or set the focus to whatever listens for click events
        flash.Lib.current.stage.focus = flash.Lib.current.stage;
        flash.Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, 
                                                onStageKeyUp);
        // this is uneccessary but i prefer to be explicit.
        this.stf = new StyledTextField(14);
        this.addChild(stf);

        this.cc = new ColorChanger(200, 500);
        this.cc.y = 20;
        flash.Lib.current.addChild(this.cc);
        this.add_image();

    }

    public function add_image(){
        var im = new Image('smiley.png', function(b:Bitmap){ trace('loaded'); });
        im.x = 300;
        im.y = 20;
        this.addChild(im);
        im.addEventListener(MouseEvent.CLICK, function(e:MouseEvent){
            // EXAMPLE of accessing the pixels directly.
            var ci = im.bitmap.bitmapData.getPixel(
                           Math.round(e.localX), Math.round(e.localY));
            // EXAMPLE of calling a javascript function.
            ExternalInterface.call('handle_flash_image_click', e.localX, e.localY, ci);
        });
    }

    /*
    handle keyboard events on the stage.
    */
    public function onStageKeyUp(e:KeyboardEvent){
        trace(e.charCode); 
        // EXAMPLE of handling keyboard event.

        // better to use a switch statement if lot's of keys...
        if(e.charCode == 97){
            if(stf.fontSize > 35){ return; }
            stf.setFontSize(stf.fontSize + 1); 
        }
        else if (e.charCode == 115){
            if(stf.fontSize < 3){ return; }
            stf.setFontSize(stf.fontSize - 1); 
            
        }
    }


}

class StyledTextField extends TextField {
    public var fontSize:Int;
    static var msg:String = "Use 'a' and 's' keys to adjust font size of this message";
    public function new(fontSize:Int=15){
        super();
        this.fontSize = fontSize;
        this.styleSheet = new StyleSheet();
        // EXAMPLE set style for stuff in '<p>' tags.
        this.styleSheet.setStyle('p', {fontSize: this.fontSize,
                                    display: 'inline',
                                    fontFamily: '_sans'});
        this.htmlText = '<p>' + StyledTextField.msg + '</p>';
        this.borderColor      = 0xcccccc;
        this.opaqueBackground = 0xf4f4f4;
        this.autoSize         = flash.text.TextFieldAutoSize.LEFT;
        this.height = 200;

    }
    
    public function setFontSize(fontSize:Int){
        this.fontSize = fontSize;
        this.styleSheet.setStyle('p', {fontSize: this.fontSize});
    }

}


class Image extends Sprite {

    public var path:String;
    public var bitmap:Bitmap;
    public var onLoaded:Bitmap->Void;
    private var _loader:Loader;
    // EXAMPLE of using an loaded via http request.
    /* take a path and a callback to be called when the image is loaded:
     var i = new Image('/some/image.png', function(b:Bitmap){ 
                    // do something with b  or b.bitmapData...
                    trace('image is loaded');
              });
    */
    public function new(path:String, onLoaded:Bitmap->Void=null){
        super();
        this.path = path;
        this._loader = new Loader();
        this._loader.load(new URLRequest(path));
        this.onLoaded = onLoaded;
        this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
        
    }

    private function onComplete(e:Event) {
        // EXAMPLE: access the data as  Bitmap
        this.bitmap = cast(this._loader.content, Bitmap);
        this.addChild(this.bitmap);
        this.onLoaded(this.bitmap);
    }
    
}

class ColorChanger extends Sprite {
    public var w:Int;
    public var h:Int;
    public function new(w:Int, h:Int){
        super();
        this.w = w;
        this.h = h;
        this.changeColor();

        // EXAMPLE: getting javascript to call flash:
        // map the string name called from javascript to the method in flash
        // keep them the same for least confusion.
        ExternalInterface.addCallback('changeColor', this.changeColor);
    }

    // called from js as flashmovie.changeColor(some_color);
    public function changeColor(c:Int=0xff0000){
        var g = this.graphics;
        g.beginFill(c);
        g.drawRect(0, 0, this.w, this.h);
        g.endFill();
    }

}
