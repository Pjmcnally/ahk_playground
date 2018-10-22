/*  Automate process of importing the UPDB
*/

; Classes
; ==============================================================================
class UpdbInterface {
    __New() {
        /*  Create new UpdbInterface Instance. Build GUI and prepare log file.
        */
        This.BuildGui()
        This.logFilePath := This.LogGeneratePath()
        This.LogWriteStart()
        This.PreCheck()
    }

    __Configure() {
        /*  Configure UpdbInterface for import run.
        */
        GuiControl, Hide, _button
        string =
        ( LTrim Join`r`n  ; Trims indentation and add line breaks between lines

            Configuring settings
            ====================
        )
        This.Log(string)
        This.UpdateStatus("Configuring Settings...")
        This.SetColors()
        This.SetWindowSize()
        This.SetCustomers()
        This.SetImportButtonLocation()
    }

    __PrepareImport() {
        /*  Prepare for Import run and wait for user input to begin.
        */
        This.UpdateProgressBar(0)
        This.UpdateStatus("Waiting for User...")
        string =
        ( LTrim Join`r`n  ; Trims indentation and add line breaks between lines

            Please select the customers you wish to import in the UPDB Import Helper."
            >> Click 'Import' to begin."
        )
        This.Log(string)
        GuiControl, , _button, Import
        GuiControl, Show, _button
    }

    __ImportLoop() {
        /*  Import all checked items. Log final results.
        */
        GuiControl, Hide, _button
        For index, customer in This.customers {
            ; Check if row is checked and if yes import.
            next_row_checked := LV_GetNext(index - 1 , "Checked" )
            if (next_row_checked = index) {
                This.Import(customer)
            } else {
                This.Log(Format("`r`nSkipping Customer: {1}", customer.short_name))
                customer.status := "Skip"
            }

            ; Update UI to show status and increase progress bar
            LV_Modify(index, , , customer.status, customer.short_name)
            This.UpdateProgressBar(index / This.customers.MaxIndex() * 100)
        }
    }

    __DisplayResults() {
        /*  Display final results import process.
        */
        This.UpdateStatus("Importing Complete.`r`nPosting Results.")
        This.log("`r`nThe following items were successfully imported:")
        For index, customer in This.customers {
            if customer.status = "Done" {
                This.Log(customer.short_name)
            }
        }

        This.log("`r`nThe following items failed and were not imported:")
        For index, customer in This.customers {
            if customer.status = "Fail" {
                This.Log(customer.short_name)
            }
        }

        This.log("`r`nThe following items were skipped and were not imported:")
        For index, customer in This.customers {
            if customer.status = "Skip" {
                This.Log(customer.short_name)
            }
        }

        string =
        ( LTrim Join`r`n  ; Trims indentation and add line breaks between lines

            The import is now complete.
            The log file for this import can be found at:
            {1}
        )
        This.Log(Format(string, This.LogFilePath))
    }

    BuildGui() {
        /*  Build Gui.
        */
        Global current_action   ; I really hate Global but am not sure how to do it otherwise
        Global prog_bar         ; I really hate Global but am not sure how to do it otherwise
        Global _button          ; I really hate Global but am not sure how to do it otherwise
        Static customer_list
        Static log_window
        Gui, updb_gui:New, +AlwaysOnTop, UPDB Import Helper
        Gui, updb_gui:Font, underline s12
        Gui, updb_gui:Add, Text, x10 y10 w200, % "Current action: "
        Gui, updb_gui:Add, Text, x220 y10, % "Current Progress:"
        Gui, updb_gui:Font,  ; Reset font
        Gui, updb_gui:Add, Text, x10 y35 r3 w200 vCurrent_action,
        Gui, updb_gui:Add, Progress, x220 y35 w500 h40 cGreen BackgroundWhite +border vProg_bar
        Gui, updb_gui:Add, ListView, x10 y80 w200 h500 Grid Checked vCustomer_list, Import|Status|Name
        Gui, updb_gui:Add, Edit, ReadOnly x220 y80 w500 h500 vLog_window
        Gui, updb_gui:Add, Button, Default x10 w200 v_button gButtonAction, Ready
        Gui, updb_gui:Show
    }

    UpdateStatus(str) {
        /*  Update status section of GUI
        */
        GuiControl, , current_action, % str
    }

    UpdateProgressBar(num) {
        /*  Update progress bar of GUI.
        */
        GuiControl, , prog_bar, % num
    }

    Log(str) {
        /*  Add log entry to log file. All entries are followed by a CRLF.
        */
        FileAppend, % str . "`r`n", % This.LogFilePath
        Control, EditPaste, % str . "`r`n", Edit1, UPDB Import Helper
    }

    LogGeneratePath() {
        /*  Create log file path.

        Returns:
            str: Path to log file location.
        */
        base := "{1}\UpdbImportLog_{2}-{3}-{4}.txt"
        values := [A_Desktop, A_YYYY, A_MM, A_DD]
        file_name := Format(base, values*)

        Return file_name
    }

    LogWriteStart() {
        /*  Write opening line to log file
        */
        FormatTime, timeStr, , yyyy-MM-dd HH:mm
        This.Log(Format("Running UPDB Import starting at {1}", timeStr))
    }

    PreCheck() {
        This.UpdateStatus("Waiting for User...")
        string =
        ( LTrim Join`r`n  ; Trims indentation and add line breaks between lines

            User Setup:
            ====================
            Before beginning please move the UPDB Import Helper so it is not covering IP Tools.
            Please ensure that you are on the UPDB Import screen in IP Tools.
            Please ensure that no customers are currently checked in IP Tools.
            Please note you will not be able to use your computer while the import is in progress.

            >> Click 'Ready' when ready to proceed.
        )
        This.Log(string)
    }

    SetColors() {
        /*  Set color variables used throughout script.
        */
        This.colors := {}
        This.colors.background := "0xFFFFFF"  ; Normal background color (not loading)
        This.colors.log_background := "0xEBEBEB"  ; Background color of import log
        This.colors.checkbox := "0xFAF6F1"
    }

    SetWindowSize() {
        /*  Gets and sets window size with logging.
        */

        This.Log("Getting window size...")
        This.window := This.FindWindowSize()
        string =
        ( LTrim Join`r`n  ; Trims indentation and add line breaks between lines
            --> Window Width: {1}
            --> Window Height: {2}
            --> Window Title: {3}
        )
        values := [This.window.width, This.window.height, This.Window.title]
        This.Log(Format(string, values*))
    }

    FindWindowSize() {
        /*  Activate and find the size of IE window.

        Returns:
            dict: A dictionary containing the following values:
                x: x coord of top left corner of window relative to system
                y: y coord of top left corner of window relative to system
                width: Width of window in pixels
                height: Height of window in pixes
                title: Window Title
        */
        WinActivate, ahk_class IEFrame
        WinWaitActive, ahk_class IEFrame
        WinGetPos, x, y, w, h, A  ; A for active window
        WinGetActiveTitle, title

        res_hash := {}
        res_hash.x := x
        res_hash.y := y
        res_hash.width := w
        res_hash.height := h
        res_hash.title := title

        Return res_hash
    }

    SetCustomers() {
        /*  Finds customers with logging.
        */
        This.Log("Finding Customers...")
        This.customers := This.FindCustomers()
        This.Log(Format("--> {1} customers found.", This.customers.Length()))
    }

    FindCustomers() {
        /*  Find customers by searching import page.

        Returns:
            array: Contains customer objects. Each object contains:
                short_name: The name of the customer
                x: The x value of the customers checkbox
                y: The y value of the customers checkbox
        */
        temp_y := 200  ; y value to start searching at.
        name_x := 300  ; x value of name column (doesn't seem to change)
        checkbox_x := 200  ; x value of checkbox column (doesn't seem to change)

        customers := []  ; Customers list to be be returned

        ; Search for checkboxes from top of screen while above import button
        while (temp_y < This.window.height) {
            PixelGetColor, pixel_color, checkbox_x, temp_y
            if (pixel_color = This.Colors.CheckBox) {
                ; When a checkbox is found build a customer dictionary
                new_customer := {}
                new_customer.short_name := This.GetCustomerName(name_x, temp_y)
                new_customer.x := checkbox_x
                new_customer.y := temp_y
                customers.push(new_customer)  ; Add customer to customers list

                LV_Add("Check", , , new_customer.short_name)
            }
            temp_y += 1
            This.UpdateProgressBar(temp_y/This.window.height * 100)
        }

        Return customers
    }

    GetCustomerName(x, y) {
        /*  Get name of customer to import.

        ARGS:
            num (int): The number representing the customer (0-18)
        */
        ClipBoard := ""  ; Clear clipboard
        try_count := 0
        While (not ClipBoard and try_count < 5) {
            try_count += 1
            This.ClickLocation(x, y)  ; Click in name box
            Sleep, 50  ; Brief pause to let click register

            Send, % "^c"  ; ctrl-c to copy contents of box
            ClipWait, 1  ; Wait up to 1 second for value.
        }

        return StrReplace(Clipboard, "`r`n")
    }

    SetImportButtonLocation() {
        /*  Gets and sets import button location with logging.
        */
        This.Log("Finding import button...")
        This.import_button := This.FindImportButton()
        string =
        ( LTrim Join`r`n  ; Trims indentation and add line breaks between lines
            --> Import button x:
            --> Import button y:
        )
        values := [This.import_button.x, This.import_button.y]
        This.Log(Format(string, values*))
    }

    FindImportButton() {
        /*  Find the location of the import button

        Returns:
            dict: A dictionary containing the following values:
                x: x coord of center of input button
                y: y coord of center of input button
        */
        import_button := {}  ; Create dict to store import_button attributes
        import_button.x := This.window.width - 100  ; Set x near left of screen

        last_customer := This.customers[This.customers.MaxIndex()]
        import_button.y := last_customer.y + 40

        return import_button
    }

    FormatDuration(milli) {
    /*  A function to convert milliseconds to readable time.

        Args:
            milli (int): number of milliseconds
        Returns:
            Str: The formatted string in hh:mm:ss
    */
    sec := mod(milli //= 1000, 60)
    min := mod(milli //= 60, 60)
    hou := milli // 60
    Return Format("{1:02d}:{2:02d}:{3:02d}", hou, min, sec)
}

    WaitForImport(customer) {
        /*  Wait for import to complete. Use color of screen to determine state.

        Args:
            (obj) customer: An object containing customer details

        Returns:
            Str: A string representation of the duration of the import.
        */
        ; Check a specific spot for color change
        ; Spot is 100 pixels to the left of the import button
        spot_x := This.import_button.x - 100
        spot_y := This.import_button.y

        ; Setup time and pause variables.
        import_start := A_TickCount
        pause_interval := 1000

        ; Setup status string and values.
        base_str =
        ( LTrim Join`r`n  ; Trims indentation and add line breaks between lines
            Importing: {1}
            Attempt number: {2}
            Attempt duration: {3}
        )
        values := [customer.short_name, customer.try_count, ""]

        importing := True
        while importing {
            ; Update duration calculation and values array.
            duration := This.FormatDuration(A_TickCount - import_start)
            values[3] := duration

            ; Update status
            This.UpdateStatus(Format(base_str, values* ))

            ; Wait for import check if still importing
            Sleep, pause_interval
            WinActivate, % This.window.title
            PixelGetColor, pixel_color, spot_x, spot_y

            ; If import complete set importing to false
            if (pixel_color = This.colors.background) {
                importing := False
            }
        }

        return duration
    }

    Import(customer) {
        /*  Import specified item.

        ARGS:
            item (dict): An object containing customer attributes and info.
        */
        ; Setup new customer attributes
        max_tries := 5
        customer.is_checked := False  ; Assume checkbox is not checked
        customer.success := False
        customer.try_count := 0

        This.Log(Format("`r`nImporting Customer: {1}", customer.short_name))
        This.Log("============================================================")
        While (customer.try_count < max_tries) {
            customer.try_count += 1

            ; If customer was already checked (after a failure) leave alone.
            if (not customer.is_checked) {
                This.ClickLocation(customer.x, customer.y)
                customer.is_checked := True
            }

            ; Start import and wait for import to finish
            This.ClickLocation(This.import_button.x, This.import_button.y)
            duration := This.WaitForImport(customer)

            ; Check Import results and act accordingly.
            This.Log("Import Complete. Checking results...")
            customer.success := This.CheckResults()

            ; If import succeeded update status/log and exit function
            if customer.success {
                customer.status := "Done"
                base_str =
                ( LTrim Join`r`n
                    {1} import successful
                    Import duration: {2}
                )
                values := [customer.short_name, duration]
                This.Log(Format(base_str, values*))
                Return customer
            ; If max try count met update status/log and exit function
            } else if (customer.try_count >= max_tries) {
                customer.status := "Fail"
                This.ClickLocation(customer.x, customer.y)  ; Uncheck customer.
                base_str =
                ( LTrim Join`r`n
                    Import failed {1} times.
                    Import duration: {2}.
                    Abandoning {3}.`r`n
                )
                values := [max_tries, duration, customer.short_name]
                This.Log(Format(base_str, values*))
                Return customer
            ; Otherwise update status/log and try again.
            } else {
                base_str =
                ( LTrim Join`r`n
                    Import failed {1} times.
                    Import duration: {2}.
                    Retrying {3}.`r`n
                )
                values := [customer.try_count, duration, customer.short_name]
                This.Log(Format(base_str, values*))
            }
        }
    }

    CheckResults() {
        /*  Check the results of am import run.

        RETURNS:
            (bool): Boolean referring to success of import run.
        */
        pattern := "FINISHED: [1] Items Processed - [1] Successful, [0] Errors"
        res := This.GetResults()
        This.Log(res)

        return InStr(res, pattern) > 0
    }

    GetResults() {
        /*  Get results string by copying contents of output box of import.
        */
        try_count = 0
        res := ""

        While (not res) {
            x := This.import_button.x
            y := This.import_button.y + 100

            This.ClickLocation(x, y)  ; Click in results box
            Sleep, 200

            Send, % "^a"  ; ctrl-a to select all text
            Sleep, 200

            if (try_count < 5) {
                ; True to persist clipboard, False to not skip error if no text
                res := get_highlighted(persist:=True, e:=False)
                try_count += 1
            } else {
                res := "ERROR: Unable to extract results"
            }
        }

        return res
    }

    ClickLocation(x, y) {
        /*  Activate window and click specific location
        */
        WinActivate, % This.window.title
        WinWaitActive, % This.window.title
        MouseClick, Left, x, y
    }
}

; Hotkeys || ^ = Ctrl, ! = Alt, + = Shift
; ==============================================================================
^!i::
    KeyWait, ctrl, L
    KeyWait, alt, L

    Global updb := New UpdbInterface
return

ButtonAction() {
    GuiControlGet, updb_status, , _button

    if (updb_status = "Ready") {
        updb.__Configure()
        updb.__PrepareImport()
    } else if (updb_status = "Import") {
        updb.__ImportLoop()
        updb.__DisplayResults()
    }
}
