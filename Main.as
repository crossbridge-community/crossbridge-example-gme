/*
 * =BEGIN MIT LICENSE
 * 
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 The CrossBridge Team
 * https://github.com/crossbridge-community
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 * =END MIT LICENSE
 *
 */
package
{
  import flash.display.Sprite;
  import flash.text.TextField;
  import flash.events.Event;
  import crossbridge.GME.CModule;
  import crossbridge.GME.vfs.RootFSBackingStore;

  public class Main extends Sprite
  {
    public function Main()
    {
      CModule.vfs.addBackingStore(new RootFSBackingStore(), null);
      addEventListener(Event.ADDED_TO_STAGE, initCode);
    }

    private function doDemo():void
    {
      const sampleRate:int = 44100;
      var musicEmuPtr:int = CModule.malloc(4);
      handleError(libgme.gme_open_file("test.nsf", musicEmuPtr, sampleRate));
      var musicEmu:int = CModule.read32(musicEmuPtr);
      handleError(libgme.gme_start_track(musicEmu, 0));

      libgme.wave_open(sampleRate, "out.wav");
      libgme.wave_enable_stereo();

      const bufSize:int = 1024;
      var bufPtr:int = CModule.malloc(bufSize);
      while (libgme.gme_tell(musicEmu) < (10 * 1000)) {
        handleError(libgme.gme_play(musicEmu, bufSize, bufPtr));
        libgme.wave_write(bufPtr, bufSize);
      }

      libgme.gme_delete(musicEmu);
      libgme.wave_close();
      CModule.free(bufPtr);
      CModule.free(musicEmuPtr);

    }

    private function handleError(err:String):void
    {
      if (err) {
        throw err;
      }
    }
 
    public function initCode(e:Event):void
    {
      CModule.startAsync(this);
      
      var tf:TextField = new TextField;
      tf.multiline = true;
      tf.width = stage.stageWidth;
      tf.height = stage.stageHeight;
      addChild(tf);

      try {
        doDemo();
        tf.appendText("done!");
      } catch (e:*) {
        tf.appendText("error: " + e);
      }
    }
  }
}
