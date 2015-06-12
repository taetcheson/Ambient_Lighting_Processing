//Developed by Rajarshi Roy
import java.awt.Robot; // Java library that lets us take screenshots
import java.awt.AWTException;
import java.awt.event.InputEvent;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;
import java.awt.Dimension;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.awt.GraphicsConfiguration;
import processing.serial.*;

Serial port;
Robot robby;
int _displayWidth;
int _displayHeight;

void setup()
{
    frameRate(25);
    
    _displayWidth = 1360;
    _displayHeight = 768;

    port = new Serial(this, "COM4", 9600);
    size(100, 100); // window size (doesn't matter)
    try // standard Robot class error check
    {
        robby = new Robot();
    }
    catch (AWTException e)
    {
        println("Robot class not supported by your system!");
        exit();
    }
}

void draw()
{
    int pixelDivisor = 4; // adjust to tune performance
    int sampleWidth = _displayWidth / pixelDivisor;
    int sampleHeight = _displayHeight / pixelDivisor;
    int samplePixels = sampleWidth * sampleHeight;

    // get screenshot into object "screenshot" of class BufferedImage
    BufferedImage screenshot = robby.createScreenCapture(new Rectangle(new Dimension(_displayWidth, _displayHeight)));

    float r = 0;
    float g = 0;
    float b = 0;
    int i = 0;
    int j = 0;
    for (i = 0; i < _displayWidth; i += pixelDivisor)
    {
        for (j = 0; j < _displayHeight; j += pixelDivisor)
        {
            // sample each pixel
            int pixel = screenshot.getRGB(i, j); // ARGB variable with 32 int bytes where sets of 8 bytes are: Alpha, Red, Green, Blue
            // shift and mask LSB
            r += (int)(0xFF & (pixel >> 16));
            g += (int)(0xFF & (pixel >> 8));
            b += (int)(0xFF & (pixel));
        }
    }

    // find average color
    // TODO: use HSV color space for better results
    r /= samplePixels;
    g /= samplePixels;
    b /= samplePixels;

    // compensate for differences in LED color intensity
    float r_, g_, b_;
    r_ = r;
    g_ = g * 0.30;
    b_ = b * 0.27;

    // send color to Arduino
    port.write(0xFF); // marker for synchronization
    port.write((byte) (r_));
    port.write((byte) (g_));
    port.write((byte) (b_));
    delay(10); // delay for safety

    // make window background average color (disable once done?)
    //background(r, g, b);
}