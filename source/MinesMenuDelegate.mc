import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// class MinesMenuDelegate extends WatchUi.MenuInputDelegate 
// {

//     function initialize() 
//     {
//         MenuInputDelegate.initialize();
//     }

//     function onMenuItem(item as Symbol) as Void 
//     {
//         if (item == :item_1) {
//             System.println("Exit");
//             System.exit();

//         } else if (item == :item_2) {
//             System.println("item 2");

//         }
//     }

// }

//! The app settings menu
class MinesMenu extends WatchUi.Menu2 
{

    //! Constructor
    public function initialize() 
    {
        Menu2.initialize({:title=>"Settings"});
    }
}

//! Input handler for the app settings menu
class MinesMenuDelegate extends WatchUi.Menu2InputDelegate 
{

    //! Constructor
    public function initialize() 
    {
        Menu2InputDelegate.initialize();
    }

    //! Handle a menu item being selected
    //! @param menuItem The menu item selected
    public function onSelect(menuItem as MenuItem) as Void 
    {
        if (menuItem instanceof ToggleMenuItem) 
        {
            Application.Properties.setValue(menuItem.getId() as String, menuItem.isEnabled() as Number);
        }

        if((menuItem.getId() as String).equals("Exit"))
        {
            //exit
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            WatchUi.popView(WatchUi.SLIDE_RIGHT);

            //System.exit();
        }

        else if ((menuItem.getId() as String).equals("NewGame"))
        {
            getApp().n_cells = Application.Properties.getValue("SizeField");
            getApp().n_mines = Application.Properties.getValue("NumberMines");
    
            getApp().engine.stop(); //avoid timer errors
            getApp().engine = null; // free the menory
            getApp().engine = new MinesEngine(getApp().n_cells,getApp().n_mines);

            WatchUi.popView(WatchUi.SLIDE_RIGHT);

            WatchUi.requestUpdate();
        }

        else if ((menuItem.getId() as String).equals("SaveGame"))
        {

            getApp().saveGame();

            WatchUi.popView(WatchUi.SLIDE_RIGHT);

            WatchUi.requestUpdate();
        }


        else if ((menuItem.getId() as String).equals("LoadGame"))
        {

            getApp().loadGame();

            WatchUi.popView(WatchUi.SLIDE_RIGHT);

            WatchUi.requestUpdate();
        }

        else if ((menuItem.getId() as String).equals("SizeField"))
        {
            var value = Application.Properties.getValue("SizeField") as Number;

            var new_value = 2 + (((value-2) + 1) % 15);

            Application.Properties.setValue("SizeField", new_value);

            menuItem.setSubLabel(new_value.toString()+"x"+new_value.toString());

            // WatchUi.requestUpdate();
        }

        else if ((menuItem.getId() as String).equals("NumberMines"))
        {
            var value = Application.Properties.getValue("NumberMines") as Number;

            var new_value = (value + 2) % 51;

            Application.Properties.setValue("NumberMines", new_value);

            menuItem.setSubLabel(new_value.toString());

            // WatchUi.requestUpdate();
        }

        // System.println(menuItem.getId() as String);
        

        // else
        // {
        //     var value = Application.Properties.getValue(menuItem.getId() as String) as Number;

        //     var new_value = (value + 1) % 25;

        //     Application.Properties.setValue(menuItem.getId() as String, new_value);

        //     menuItem.setSubLabel(new_value.toString());

        //     // WatchUi.requestUpdate();

        //     System.println("hit");
        // }

        
    }
}