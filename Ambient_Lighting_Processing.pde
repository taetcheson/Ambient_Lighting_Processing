//Developed by Rajarshi Roy
import java.awt.Robot; //java library that lets us take screenshots
import java.awt.AWTException;
import java.awt.event.InputEvent;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;
import java.awt.Dimension;
import processing.serial.*; //library for serial communication


Serial port; //creates object "port" of serial class
Robot robby; //creates object "robby" of robot class

void setup()
{
    frameRate(25);
    port = new Serial(this, "COM4", 9600); //set baud rate
    size(100, 100); //window size (doesn't matter)
    try //standard Robot class error check
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
    int pixelDivisor = 2; // adjust to tune performance
    int sampleWidth = displayWidth / pixelDivisor;
    int sampleHeight = displayHeight / pixelDivisor;
    int samplePixels = sampleWidth * sampleHeight;
    
    // get screenshot into object "screenshot" of class BufferedImage
    BufferedImage screenshot = robby.createScreenCapture(new Rectangle(new Dimension(displayWidth, displayHeight)));

    int pixel; // ARGB variable with 32 int bytes where sets of 8 bytes are: Alpha, Red, Green, Blue
    float r = 0;
    float g = 0;
    float b = 0;
    int i = 0;
    int j = 0;
    for (i = 0; i < displayWidth; i += pixelDivisor)
    {
        for (j = 0; j < displayHeight ; j += pixelDivisor)
        {
            pixel = screenshot.getRGB(i, j);
            r += (int)(255 & (pixel >> 16));
            g += (int)(255 & (pixel >> 8));
            b += (int)(255 & (pixel));
        }
    }
    r /= samplePixels;
    g /= samplePixels;
    b /= samplePixels;

    port.write(0xFF); // marker for synchronization
    port.write((byte) (r));
    port.write((byte) (g));
    port.write((byte) (b));
    delay(10); // delay for safety

    background(r, g, b); // make window background average color
}

