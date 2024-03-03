local Popup=require('nui.popup')
local Layout=require('nui.layout')
-- local event = require("nui.utils.autocmd").event
-- local Input = require("nui.input")
local File=require('sdftools/util/fileutil')
local Config=require('sdftools/config')
local Dialog=require('sdftools/util/dialogutil')
local Output=require('sdftools/output')

local M={}

local ObjectUI={}

--oTable
---objectTable: ObjectTableElement[]
----ObjectTableElement
----type: string
----objects: SDFObject[]
-----SDFObject
-----name: string
-----sel: boolean
function ObjectUI:new(oTable,submitCallback)
    setmetatable(oTable,self)
    self.__index=self
    self.objectTable=oTable
    vim.api.nvim_command('highlight default HighlightLine guifg=#0CFE47 gui=bold ctermfg=198 cterm=bold' )
    local namespace_id=vim.api.nvim_create_namespace('HighlightLineNamespace')
    self.nameSpaceId=namespace_id
        vim.api.nvim_command('highlight default HighlightLine guifg=#0CFE47 gui=bold ctermfg=198 cterm=bold' )

    self.submitCallback=submitCallback

    local leftPopup=Popup({
        enter=true,
        border="double",
        buf_options={
            modifiable=true,
        }
    })

    local rightPopup=Popup({
        border="single",
        buf_options={
            modifiable=true
        }
    })

    local layout=Layout(
        {
            position="50%",
            size={
                width=90,
                height=40
            }
        },
        Layout.Box({
            Layout.Box(leftPopup,{size="35%"}),
            Layout.Box(rightPopup,{size="65%"}),
        },{dir="row"})
    )

    self.leftWindow=leftPopup
    self.rightWindow=rightPopup
    self.layout=layout

    self:_setBufReadOnly(leftPopup.bufnr)
    self:_setBufReadOnly(rightPopup.bufnr)

    return oTable

end

function ObjectUI:mount()
    self.layout:mount()

    self:drawWindow()

end

function ObjectUI:unmount()
    self.layout:unmount()

end

function ObjectUI:getSelections()
    local ret={}
    for _,v in pairs(self.objectTable) do
        for _,ov in pairs(v.objects) do
            if ov.sel then
                table.insert(ret,ov.name)
            end
        end

    end

    return ret
end

function ObjectUI:setKeyMaps()

    local focusWindow=function(winid)
        vim.api.nvim_set_current_win(winid)
    end

    self.leftWindow:map('n','l',function()
        focusWindow(self.rightWindow.winid)
    end)

    self.leftWindow:map('n','s',function()
        self:toggleType()
    end)


    self.rightWindow:map('n','h',function()
        focusWindow(self.leftWindow.winid)
    end)

    self.rightWindow:map('n','l','')

    self.rightWindow:map('n','s',function()
        self:toggleSelection()
    end,{remap=true})

    for _,v in pairs({self.leftWindow,self.rightWindow}) do
        v:map('n','q',function()
            self:unmount()
        end)

        v:map('n','<enter>',function()
            self:unmount()
            local selected=self:getSelections()
            self.submitCallback(selected)
        end)
    end




end

function ObjectUI:drawWindow()
    local typeLines={}

    self:setKeyMaps()

    local popups={self.leftWindow,self.rightWindow}

    for _, popup in pairs(popups) do
      popup:on("BufLeave", function()
        vim.schedule(function()
          local curr_bufnr = vim.api.nvim_get_current_buf()
          for _, p in pairs(popups) do
            if p.bufnr == curr_bufnr then
              return
            end
          end
        self:unmount()
        end)
      end)
    end


    for _,v in ipairs(self.objectTable) do
        table.insert(typeLines,v.type)
    end

    self:setLines(self.leftWindow.bufnr,0,#typeLines,false,typeLines)

   vim.api.nvim_create_autocmd("CursorMoved", {
		--group = augroup,
		buffer = self.leftWindow.bufnr,
		callback = function()
			local cursor_pos = vim.api.nvim_win_get_cursor(self.leftWindow.winid)

            self:drawRightPane(cursor_pos[1])
		end,
	})

    self:drawRightPane(1)
end

function ObjectUI:_setBufEditable(bufnr)
    vim.api.nvim_buf_set_option(bufnr,'modifiable',true)
    vim.api.nvim_buf_set_option(bufnr,'readonly',false)
end

function ObjectUI:_setBufReadOnly(bufnr)
    vim.api.nvim_buf_set_option(bufnr,'modifiable',false)
    vim.api.nvim_buf_set_option(bufnr,'readonly',true)
end

function ObjectUI:setLines(bufnr,startLine,endLine,strictIndexing,replacement)
    self:_setBufEditable(bufnr) 
    vim.api.nvim_buf_set_lines(bufnr,startLine,endLine,strictIndexing,replacement)
    self:_setBufReadOnly(bufnr)

end

function ObjectUI:drawRightPane(idx)
    local obj=self.objectTable[idx]


    local lines=vim.api.nvim_buf_get_lines(self.rightWindow.bufnr,0,-1,true)

    self:setLines(self.rightWindow.bufnr,0,#lines,false,{})

    local objectLines={}

    for _,v in ipairs(obj.objects) do
        table.insert(objectLines,v.name)
    end

    self:setLines(self.rightWindow.bufnr,0,#objectLines,false,objectLines)

    for k,v in ipairs(obj.objects) do
        if(v.sel) then
            self:markLine(k-1)
        end
    end
end

function ObjectUI:markLine(row)
    local current_line = vim.api.nvim_buf_get_lines(self.rightWindow.bufnr, row, row + 1, false)[1]
    local end_col = string.len(current_line)

    vim.api.nvim_buf_set_extmark(self.rightWindow.bufnr, self.nameSpaceId, row, 0, {end_row = row, end_col = end_col, hl_group='HighlightLine'})

end

function ObjectUI:unmarkLine(row)
    vim.api.nvim_buf_clear_namespace(self.rightWindow.bufnr,self.nameSpaceId,row,row+1)
end

function ObjectUI:toggleLine(typeIdx,objIdx)
    local currentObj=self.objectTable[typeIdx].objects[objIdx]


    currentObj.sel=not currentObj.sel

    if currentObj.sel then
        self:markLine(objIdx-1)
    else
        self:unmarkLine(objIdx-1)
    end

end

function ObjectUI:toggleSelection()
    local typeIdx = vim.api.nvim_win_get_cursor(self.leftWindow.winid)[1]
    local objIdx = vim.api.nvim_win_get_cursor(self.rightWindow.winid)[1]

    self:toggleLine(typeIdx,objIdx)

end

function ObjectUI:toggleType()
    local typeIdx = vim.api.nvim_win_get_cursor(self.leftWindow.winid)[1]
    local currentType=self.objectTable[typeIdx]

    for k,_ in ipairs(currentType.objects) do
        self:toggleLine(typeIdx,k)
    end
end

local splitString=function(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

local getList=function(scriptId)
    local results=vim.fn.systemlist('suitecloud object:list --scriptid '..scriptId)

    table.remove(results,1)

    return results
end

local friendlyMap = {
    addressForm = "Address Form",
    advancedpdftemplate = "Advanced PDF",
    bundleinstallationscript = "Bundle Installation Script",
    center = "Center",
    centercategory = "Center Category",
    centerlink = "Center Link",
    centertab = "Center Tab",
    clientscript = "Client Script",
    crmcustomfield = "CRM Custom Field",
    csvimport = "CSV Import",
    customglplugin = "Custom GL Plugin",
    customlist = "Custom List",
    customrecordtype = "Custom Record Type",
    customsegment = "Custom Segment",
    dataset = "Dataset",
    emailcaptureplugin = "Email Capture Plugin",
    emailtemplate = "Email Template",
    entitycustomfield = "Entity Field",
    entryForm = "Entry Form",
    financiallayout = "Financial Layout",
    integration = "Integration",
    itemcustomfield = "Item Field",
    itemoptioncustomfield = "Item Option Field",
    kpiscorecard = "KPI Scorecard",
    mapreducescript = "Map Reduce Script",
    massupdatescript = "Mass Update Script",
    othercustomfield = "Other Custom Field",
    paymentgatewayplugin = "Payment Gateway Plugin",
    plugintype = "Plugin Type",
    portlet = "Portlet",
    promotionsplugin = "Promotions Plugin",
    publisheddashboard = "Published Dashboard",
    reportdefinition = "Report Definition",
    restlet = "Restlet",
    role = "Role",
    savedsearch = "Saved Search",
    scheduledscript = "Scheduled Script",
    secret = "Secret",
    sspapplication = "SSP Application",
    sublist = "Sublist",
    subtab = "Subtab",
    suitelet = "Suitelet",
    transactionForm = "Transaction Form",
    transactionbodycustomfield = "Transaction Body Field",
    transactioncolumncustomfield = "Transaction Column Field",
    translationcollection = "Translation Collection",
    usereventscript = "User Event Script",
    workbook = "Workbook",
    workflow = "Workflow",
    workflowactionscript = "Workflow Action Script"
}

local getFriendlyTypeName=function(rawName)
    if friendlyMap[rawName] then
        return friendlyMap[rawName]
    else
        return rawName
    end
end

--@type SDFObjectType
--@field type: string
--@field objects: SDFObject[]

--@type SDFObject
--@field name: string
--@field sel: boolean

--@returns SDFObjectType[]
local formatList=function(rawList)
    local typeRet={}

    for _,v in pairs(rawList) do
        local splitTokens=splitString(v,':')

        local type=getFriendlyTypeName(splitTokens[1])
        local objectName=splitTokens[2]

        --find an existing entry in typeRet where the type field equals type
        local foundEntry=nil
        for _,entry in pairs(typeRet) do
            if(entry.type==type) then
                foundEntry=entry
            end
        end

        if foundEntry==nil then
            foundEntry={type=type,objects={}}
            table.insert(typeRet,foundEntry)
        end

        table.insert(foundEntry.objects,{name=objectName,sel=false})
    end
    return typeRet
end

local function showList(input, objectImportListCallback)
    local results=getList(input)

    local objectTable=formatList(results)
    --P({results=results,objectTable=objectTable})
    local oTable=ObjectUI:new(objectTable,objectImportListCallback)

    oTable:mount()


end

local getObjectsFolders=function()

    local cwd=vim.fn.getcwd()

    local srcPath=File.pathcombine(cwd,Config.options.sourceDir)

    local objectsPath=File.pathcombine(srcPath,'Objects')

    local objectsSubDirs=File.scanDirDirectories(objectsPath)

    table.insert(objectsSubDirs,1,objectsPath)

    local ret={}

    for _,v in ipairs(objectsSubDirs) do
        local normalizedDir=File.normalizePath(v,srcPath)

        if string.sub(normalizedDir,1,1)~='/' then
            normalizedDir='/'..normalizedDir
        end

        table.insert(ret,normalizedDir)
    end

    return ret
end

local doImport=function(folder,objects)


    local objectStr=''

    for _,v in pairs(objects) do
        objectStr=objectStr..v..' '
    end

    local command='suitecloud object:import --type ALL --destinationfolder '..folder..' --scriptid '..objectStr

    Output.runCommand(command)
end

local doImportObjects=function(objectList)
    if #objectList==0 then
        return
    end

    local objectFolders=getObjectsFolders()

    local options={}

    for _,v in ipairs(objectFolders) do
        table.insert(options,{option_text=v,value=v})
    end

    Dialog.option('Select import folder',options,function (value)
        doImport(value,objectList)
    end)

end

M.importObjects=function()
    -- local popup_options = {
    --   relative = "editor",
    --   position = "50%",
    --   size = 30,
    --   border = {
    --     style = "rounded",
    --     text = {
    --       top = "[Script Id]",
    --       top_align = "left",
    --     },
    --   },
    --   win_options = {
    --     winhighlight = "Normal:Normal",
    --   },
    -- }

    --local input=nil


    -- input = Input(popup_options, {
    --   prompt = "> ",
    --   default_value = "",
    --   -- on_close = function()
    --   --   print("Input closed!")
    --   -- end,
    --   on_submit = function(value)
    --     showList(value,objectImportListCallback)
    --   end,
    --   -- on_change = function(value)
    --   --   print("Value changed: ", value)
    --   -- end,
    -- })
    --
    -- input:mount()

    local value=vim.fn.input('ScriptId: ')

    showList(value,doImportObjects)
end

vim.api.nvim_create_user_command("TestObjectUI",function()
    M.importObjects()
end,{})


return M
