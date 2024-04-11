import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.WatchUi;

class MinesView extends WatchUi.View 
{
    function initialize() 
    {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void 
    {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void 
    {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void 
    {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        dc.clear();
        // dc.drawText(50, 50, Graphics.FONT_LARGE, "TEST", Graphics.TEXT_JUSTIFY_CENTER);
        
        var n_cells = getApp().n_cells;

        var screen_width = dc.getWidth();
        var screen_height = dc.getHeight();
        var center_x = screen_width/2;
        var center_y = screen_height/2;

        var target_field_width =  Math.cos(Math.PI/4)*screen_width;
        var target_field_height =  Math.sin(Math.PI/4)*screen_height;

        //var cell_size = 25;

        var cell_size = (target_field_width/n_cells).toNumber();

        // System.println(target_field_width);
        // System.println(cell_size);

        var position_x = center_x - (cell_size*n_cells)/2;
        var position_y = center_y - (cell_size*n_cells)/2;

        //draw cursor
        var cursor_pos = getApp().engine.getCursor();

        dc.setPenWidth(2);

        //draw the cells
        for(var x = 0; x < n_cells; x++)
        {
            for(var y = 0; y < n_cells; y++)
            {
                var cell = getApp().engine.getCell(x, y);

                if(cell == CELL_UNDISCOVERED)
                {
                    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
                    dc.fillRectangle(position_x + x*cell_size, position_y + y*cell_size, cell_size, cell_size);
                }

                else if(cell == CELL_UNDISCOVERED_FLAGGED)
                {
                    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
                    dc.fillRectangle(position_x + x*cell_size, position_y + y*cell_size, cell_size, cell_size);
                    
                    dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_LT_GRAY);
                    dc.drawText(position_x + x*cell_size + cell_size/2, position_y + y*cell_size, Graphics.FONT_XTINY, "F", Graphics.TEXT_JUSTIFY_CENTER);

                }

                else if(cell == CELL_EMPTY)
                {
                    // dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
                    // dc.fillRectangle(position_x + cursor_pos[0]*cell_size, position_y + cursor_pos[1]*cell_size, cell_size, cell_size);
                }

                else if(cell == CELL_MINE)
                {
                    dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_BLACK);
                    dc.drawText(position_x + x*cell_size + cell_size/2, position_y + y*cell_size, Graphics.FONT_XTINY, "x", Graphics.TEXT_JUSTIFY_CENTER);
                }

                else
                {
                    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                    dc.drawText(position_x + x*cell_size + cell_size/2, position_y + y*cell_size, Graphics.FONT_XTINY, getApp().engine.getCell(x, y), Graphics.TEXT_JUSTIFY_CENTER);
                }

                //draw the frame
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.drawRectangle(position_x + x*cell_size, position_y + y*cell_size, cell_size, cell_size);

            }
        }

        //draw the cursor
        dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_BLACK);
        dc.drawRectangle(position_x + cursor_pos[0]*cell_size, position_y + cursor_pos[1]*cell_size, cell_size, cell_size);


        //draw the timer
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(center_x, position_y + cell_size*n_cells, Graphics.FONT_TINY, getApp().engine.getSecondsElapsed(), Graphics.TEXT_JUSTIFY_CENTER);


        if(getApp().engine.getStatus() == STATUS_LOST)
        {
        
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
            dc.drawText(center_x,center_y+30, Graphics.FONT_TINY,"Lost!",Graphics.TEXT_JUSTIFY_CENTER);

        }

        if(getApp().engine.getStatus() == STATUS_WON)
        {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
            dc.drawText(center_x,center_y+30, Graphics.FONT_TINY,"Won!",Graphics.TEXT_JUSTIFY_CENTER);

        }



    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void 
    {

    }

}
