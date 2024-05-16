import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;


class MinesDelegate extends WatchUi.BehaviorDelegate 
{

    function initialize() 
    {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean 
    {
        var menu= new $.MinesMenu();

        menu.addItem(new WatchUi.MenuItem("New Game", null, "NewGame", null));

        var val = Application.Properties.getValue("NumberMines") as Number;
        menu.addItem(new WatchUi.MenuItem("Number of Mines", val.toString(), "NumberMines", null));
        
        val = Application.Properties.getValue("SizeField") as Number;
        menu.addItem(new WatchUi.MenuItem("Board Size", val.toString(), "SizeField", null));

        val = Application.Properties.getValue("UseTouchTap") ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Tap to Select", null, "UseTouchTap", val, null));

        val = Application.Properties.getValue("UseTouchHold") ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Long Press Flag", null, "UseTouchHold", val, null));

        menu.addItem(new WatchUi.MenuItem("Save Game", null, "SaveGame", null));
        menu.addItem(new WatchUi.MenuItem("Load Game", null, "LoadGame", null));


        menu.addItem(new WatchUi.MenuItem("Exit", null, "Exit", null));

        WatchUi.pushView(menu, new $.MinesMenuDelegate(), WatchUi.SLIDE_UP);

        return true;
    }

    function onKey(keyEvent) 
    {
        // System.println("key");         // e.g. KEY_MENU = 7


        //start/stop key
        if(keyEvent.getKey() == 4)
        {
            if(getApp().engine.getStatus() == STATUS_ACTIVE)
            {
                // System.println("key");         // e.g. KEY_MENU = 7
                var cursor_pos = getApp().engine.getCursor();
                getApp().engine.discoverCell(cursor_pos[0], cursor_pos[1]);

                WatchUi.requestUpdate();
            }

            else if ((getApp().engine.getStatus() == STATUS_WON) || (getApp().engine.getStatus() == STATUS_LOST))
            {
                getApp().engine.stop(); //avoid timer errors
                getApp().engine = null; // free the memory
                getApp().engine = new MinesEngine(getApp().n_cells,getApp().n_mines);

                WatchUi.requestUpdate();
            }

        }

        if(keyEvent.getKey() == KEY_DOWN)
        {
            if(getApp().engine.getStatus() == STATUS_ACTIVE)
            {
                // System.println("key");         // e.g. KEY_MENU = 7
                var cursor_pos = getApp().engine.getCursor();

                getApp().engine.setFlag(cursor_pos[0], cursor_pos[1]);

                WatchUi.requestUpdate();
            }

        }

        if(keyEvent.getKey() == KEY_ESC)
        {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);

            // System.exit();
        }

        // //debugging
        // if(keyEvent.getKey() == 13)
        // {
        //     var size = getApp().engine.getFieldSize();
        //     var cursor_pos = getApp().engine.getCursor();

        //     getApp().engine.setCursor(cursor_pos[0], (cursor_pos[1] + 1) % size);
        //     WatchUi.requestUpdate();

        // }


        // //debugging
        // if(keyEvent.getKey() == 255)
        // {
        //     var size = getApp().engine.getFieldSize();
        //     var cursor_pos = getApp().engine.getCursor();

        //     getApp().engine.setCursor((cursor_pos[0] + 1) % size, cursor_pos[1]);
        //     WatchUi.requestUpdate();

        // }

        //System.println("Key: " + keyEvent.getKey());
        return true;
    }

    //debugging
    // function onTap(clickEvent) 
    // {
    //     System.println("click");      // e.g. CLICK_TYPE_TAP = 0

    //     // var size = getApp().engine.getFieldSize();
    //     // var cursor_pos = getApp().engine.getCursor();
    //     // getApp().engine.setCursor((cursor_pos[0] + 1) % size, cursor_pos[1]);

    //     return true;
    // }

    function onSwipe(swipeEvent) 
    {
        //System.println("swipe"); // e.g. SWIPE_DOWN = 2

        var size = getApp().engine.getFieldSize();

        if(getApp().engine.getStatus() == STATUS_ACTIVE)
        {
            if(swipeEvent.getDirection() == SWIPE_DOWN)
            {
                var cursor_pos = getApp().engine.getCursor();

                getApp().engine.setCursor(cursor_pos[0], (cursor_pos[1] + 1) % size);
            }

            if(swipeEvent.getDirection() == SWIPE_UP)
            {
                var cursor_pos = getApp().engine.getCursor();
                getApp().engine.setCursor(cursor_pos[0], (size + cursor_pos[1] - 1) % size);
            }

            if(swipeEvent.getDirection() == SWIPE_LEFT)
            {
                var cursor_pos = getApp().engine.getCursor();
                getApp().engine.setCursor((size + cursor_pos[0] - 1) % size, cursor_pos[1]);
            }

            if(swipeEvent.getDirection() == SWIPE_RIGHT)
            {
                var cursor_pos = getApp().engine.getCursor();
                getApp().engine.setCursor((cursor_pos[0] + 1) % size, cursor_pos[1]);
            }
        }
        WatchUi.requestUpdate();
        

        return true;
    }

    function onTap(clickEvent)
    {
        if(Application.Properties.getValue("UseTouchTap") as Boolean == true)
        {
            var x = clickEvent.getCoordinates()[0];
            var y = clickEvent.getCoordinates()[1];

            //System.println("tap" + clickEvent.getCoordinates());

            getApp().view.handleTap(x, y);

            return true;
        }

        return false;
    }

    function onHold(clickEvent)
    {
        if(Application.Properties.getValue("UseTouchHold") as Boolean == true)
        {
            //do a set flag
            if(getApp().engine.getStatus() == STATUS_ACTIVE)
            {
                var cursor_pos = getApp().engine.getCursor();

                getApp().engine.setFlag(cursor_pos[0], cursor_pos[1]);

                WatchUi.requestUpdate();
            }

            return true;
        }

        return false;
    }
    
    // function onBack()
    // {
    //     return false;
    // }

}