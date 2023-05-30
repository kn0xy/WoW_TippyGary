--[[
	Keys set in the parent frame table
	----------------------------------
	initFunc			function	function(self,list) that is run before the dropdown menu is displayed
	selectValueFunc		function	function(self,entry,index) that is called when an item is selected
	isAutoSelect		boolean		when true, the parent frame will have its text set to the selected item (default true)
	isAutoClose			boolean		if false, the dropdown menu is not closed when selecting an item (default true)
	minDropdownWidth	number		the minimum allowed width of the dropdown menu
	maxShownItems		number		the maximum items shown at once in the dropdown menu before enabling the scrollbar (default 16)

	Valid keys for a dropdown menu item (filled in during "initFunc")
	-----------------------------------------------------------------
	text		The text that is displayed in the dropdown menu
	value		Value of the item, is passed on to the "selectValueFunc"
	header		If true, the item appears as a header item, and cannot be selected
	checked		Item appears selected by having a checkmark next to it
	tip			Tooltip will be shown when mouse is over item
--]]


local tdd = {};

local menu;					-- only one dropdown menu exists globally that is shared across all created dropdowns
local storage = {};			-- storage for empty tables that will be recycled for the "initFunc" list parameter

local backdrop = {
	bgFile = "Interface\\Buttons\\WHITE8X8",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 10,
	insets = { left = 2, right = 2, top = 2, bottom = 2 },
	backdropColor = CreateColor(0.1,0.1,0.1,1),
	backdropBorderColor = CreateColor(0.4,0.4,0.4,1),
};
tdd.backdrop = backdrop;

-- Used to copy backdrop colors from parent
local backdropColor = CreateColor(0,0,0);
local backdropBorderColor = CreateColor(0,0,0);

-- Constants
local MENU_ITEM_HEIGHT = 14;
local DEF_MAX_MENU_ITEMS = 16;

--------------------------------------------------------------------------------------------------------
--                                         Helper Functions                                           --
--------------------------------------------------------------------------------------------------------

-- Used for both the DropDownMenuMixin & DropDownFrameMixin
local function ApplyOurBackdrop(self,backdrop,backdropColor,backdropBorderColor)
	if (not backdropColor) then
		backdropColor = backdrop and backdrop.backdropColor or tdd.backdrop.backdropColor;
	end
	if (not backdropBorderColor) then
		backdropBorderColor = backdrop and backdrop.backdropBorderColor or tdd.backdrop.backdropBorderColor;
	end
	if (not backdrop) then
		backdrop = tdd.backdrop;
	end
	self:SetBackdrop(backdrop);
	self:SetBackdropColor(backdropColor:GetRGBA());
	self:SetBackdropBorderColor(backdropBorderColor:GetRGBA());
end

--------------------------------------------------------------------------------------------------------
--                                        DropDown Menu Mixin                                         --
--------------------------------------------------------------------------------------------------------

local DropDownMenuMixin = { ApplyOurBackdrop = ApplyOurBackdrop };

-- Calls the parent's "initFunc" to query the items
function DropDownMenuMixin:QueryItems(parent)
	local list = self.list;

	-- Clear old list
	for _, tbl in ipairs(list) do
		wipe(tbl);
		storage[#storage + 1] = tbl;
	end
	wipe(list);

	-- Init new list
	parent:initFunc(list);

	-- Show "No items" for empty lists & Update List
	if (#list == 0) then
		list[1].text = "No items";
		list[1].header = true;
	end

	return list;
end

-- Update the items used in the dropdown menu
function DropDownMenuMixin:UpdateItems()
	local parent = self.parent;
	local maxItems = self:GetMaxShownItems();

	-- Query updated items from the parent's "initFunc"
	local list = self:QueryItems(parent);

	-- Update Scroll Items
	self.scroll:UpdateScroll();

	-- Measure Width
	local maxItemWidth = parent.minDropdownWidth or 0;
	for _, tbl in ipairs(list) do
		self.measure:SetText(tbl.text);
		maxItemWidth = max(maxItemWidth,self.measure:GetWidth() + 10 + 38);
	end

	-- Adjust anchor point based on scrollbar being visible or not
	if (#list > maxItems) then
		maxItemWidth = (maxItemWidth + 12);
		self.items[1]:SetPoint("TOPRIGHT",-28,-8);
	else
		self.items[1]:SetPoint("TOPRIGHT",-16,-8);
	end

	-- Set width/height
	self:SetWidth(maxItemWidth);
	self:SetHeight(min(#list,maxItems) * MENU_ITEM_HEIGHT + 16);

	-- Anchor scrollbar bottom to the last item
	local lastItem = self.items[min(#self.items,maxItems)];
	self.scroll:SetPoint("BOTTOMRIGHT",lastItem);
end

-- Initializes the menu to show for the given parent
function DropDownMenuMixin:Initialize(parent,point,parentPoint)
	if (not parent) then
		return;
	end

	-- Set DropDown Parent
	self.parent = parent;
	self:SetParent(parent);

	-- Anchor to Parent
	self:ClearAllPoints();
	self:SetPoint(point or "TOPLEFT",parent,parentPoint or "BOTTOMLEFT");
	self:SetFrameLevel(parent:GetFrameLevel() + 4);

	-- Copy Backdrop from parent, or use default
	local backdrop = parent.GetBackdrop and parent:GetBackdrop();
	if (backdrop) then
		backdropColor:SetRGB(parent:GetBackdropColor());
		backdropBorderColor:SetRGBA(parent:GetBackdropBorderColor());
		self:ApplyOurBackdrop(backdrop,backdropColor,backdropBorderColor);
	else
		self:ApplyOurBackdrop(tdd.backdrop);
	end

	-- updates the menu items
	self:UpdateItems();
end

function DropDownMenuMixin:GetMaxShownItems()
	return self.parent.maxShownItems or DEF_MAX_MENU_ITEMS;
end

--------------------------------------------------------------------------------------------------------
--                                  Private DropDown Menu Functions                                   --
--------------------------------------------------------------------------------------------------------

-- MenuItem OnClick
local function MenuItem_OnClick(self,button)
	local entry = menu.list[self.index];
	local parent = menu.parent;
	-- select the value
	if (parent.isAutoSelect) then
		parent:SetText(entry.text);
		parent.selectedValue = entry.value;
	end
	parent:selectValueFunc(entry,self.index);
	-- hide or update the menu items
	if (parent.isAutoClose == nil) or (parent.isAutoClose) then
		menu:Hide();
	else
		menu:UpdateItems();
	end
end

-- MenuItem OnEnter
local function MenuItem_OnEnter(self)
	local entry = menu.list[self.index];
	if (type(entry.tip) == "string") then
		GameTooltip_SetDefaultAnchor(GameTooltip,self);
		GameTooltip:AddLine(entry.text,1,1,1);
		GameTooltip:AddLine(entry.tip,nil,nil,nil,1);
		GameTooltip:Show();
	end
end

-- HideGTT
local function HideGTT()
	GameTooltip:Hide();
end

-- Create Dropdown Menu Item Button
local function CreateMenuItem()
	local item = CreateFrame("Button",nil,menu);
	item:SetHeight(MENU_ITEM_HEIGHT);
	item:SetHitRectInsets(-12,-10,0,0);
	item:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	item:SetScript("OnClick",MenuItem_OnClick);
	item:SetScript("OnEnter",MenuItem_OnEnter);
	item:SetScript("OnLeave",HideGTT);

	item.text = item:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
	item.text:SetPoint("LEFT",2,0);

	item.check = item:CreateTexture(nil,"ARTWORK");
	item.check:SetTexture(READY_CHECK_READY_TEXTURE);
	item.check:SetSize(14,14);
	item.check:SetPoint("RIGHT",item,"LEFT");
	item.check:Hide();

	if (#menu.items == 0) then
		item:SetPoint("TOPLEFT",20,-8);
		menu.scroll:SetPoint("TOPLEFT",item);
	else
		item:SetPoint("TOPLEFT",menu.items[#menu.items],"BOTTOMLEFT");
		item:SetPoint("TOPRIGHT",menu.items[#menu.items],"BOTTOMRIGHT");
	end

	menu.items[#menu.items + 1] = item;
	return item;
end

-- Updates the visible dropdown menu items in scroll range
local function UpdateScroll(self)
	local maxItems = menu:GetMaxShownItems();
	local shownItems = min(#menu.list,maxItems);
	FauxScrollFrame_Update(self,#menu.list,maxItems,MENU_ITEM_HEIGHT);
	local index = self.offset;
	local lastItem = 0;
	for i = 1, shownItems do
		lastItem = i;
		index = (index + 1);
		local item = menu.items[i] or CreateMenuItem();
		local entry = menu.list[index];

		item.index = index;
		item.text:SetText(entry.text);
		item.text:SetTextColor(1,entry.header and 0.82 or 1,entry.header and 0 or 1);

		(entry.header and item.Disable or item.Enable)(item);

		local checkState = (entry.checked) or (entry.checked == nil and menu.parent.isAutoSelect and entry.value ~= nil and entry.value == menu.parent.selectedValue);
		item.check:SetShown(checkState);

		item:Show();
	end
	-- hide the rest
	for i = lastItem + 1, #menu.items do
		menu.items[i]:Hide();
	end
end

-- Creates the DropDown menu with item buttons and scrollbar
local function CreateDropDownMenu()
	menu = CreateFrame("Frame",nil,nil,BackdropTemplateMixin and "BackdropTemplate");	-- 9.0.1: Using BackdropTemplate

	menu:SetToplevel(true);
	menu:SetClampedToScreen(true);
	menu:SetFrameStrata("FULLSCREEN_DIALOG");
	menu:SetScript("OnHide",function(self) if (self:IsShown()) then self:Hide(); end end);	-- hides the menu if parent is hidden
	menu:Hide();

	menu.scroll = CreateFrame("ScrollFrame","tgDropDownScroll",menu,"FauxScrollFrameTemplate");
	menu.scroll:SetScript("OnVerticalScroll",function(self,offset) FauxScrollFrame_OnVerticalScroll(self,offset,MENU_ITEM_HEIGHT,self.UpdateScroll); end);
	menu.scroll.UpdateScroll = UpdateScroll;

	-- fontString used to measure text width
	menu.measure = menu:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
	menu.measure:Hide();

	menu.items = {};
	menu.list = setmetatable({},{ __index = function(t,k) t[k] = #storage > 0 and tremove(storage,#storage) or {}; return t[k]; end });

	Mixin(menu,DropDownMenuMixin);
end

--------------------------------------------------------------------------------------------------------
--                                   Public DropDown Menu Functions                                   --
--------------------------------------------------------------------------------------------------------

-- Hides the menu
function tdd:HideMenu()
	if (menu) then
		menu:Hide();
	end
end

-- Toggles menu visibility for the given parent
-- Menu hides, if already showing for given parent, otherwise it shows for the new parent
function tdd:ToggleMenu(parent,point,parentPoint)
	if (not parent) then
		return;
	end
	if (not menu) then
		CreateDropDownMenu();
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);	-- "igMainMenuOptionCheckBoxOn"
	if (menu:IsShown()) and (menu.parent == parent) then
		menu:Hide();
	else
		menu:Initialize(parent,point,parentPoint);
		menu:Show();
	end
end

--------------------------------------------------------------------------------------------------------
--                                        DropDown Frame Mixin                                        --
--------------------------------------------------------------------------------------------------------

local DropDownFrameMixin = { ApplyOurBackdrop = ApplyOurBackdrop };

-- Sets the text of the label, but can be called on the dropdown frame
function DropDownFrameMixin:SetText(text)
	self.label:SetText(text);
end

-- Init Selected DropDown Item
function DropDownFrameMixin:InitSelectedItem(selectedValue)
	if (not menu) then
		CreateDropDownMenu();
	end

	self:SetText("|cff00ff00Select Value...");	-- set before calling QueryItems() as that may override it
	self.selectedValue = selectedValue;

	local list = menu:QueryItems(self);
	for _, entry in ipairs(list) do
		if (entry.value == selectedValue) then
			self:SetText(entry.text);
			return;
		end
	end
end

--------------------------------------------------------------------------------------------------------
--                                       DropDown Frame Widget                                        --
--------------------------------------------------------------------------------------------------------

-- DropDown OnClick
local function DropDown_OnClick(self,button)
	tdd:ToggleMenu(self:GetParent(),"TOPRIGHT","BOTTOMRIGHT");
end

-- Creates a dropdown frame, which shows the selected value and handles clicking to summon the dropdown menu
-- If "width" is set to a negative value, then "minDropdownWidth" is set to the absolute value of "width"
function tdd:CreateDropDown(parent,width,initFunc,selectValueFunc,isAutoSelect,isAutoClose,maxShownItems,minDropdownWidth)
	if (not parent or not width) then
		return;
	end

	local dd = CreateFrame("Frame",nil,parent,BackdropTemplateMixin and "BackdropTemplate");	-- 9.0.1: Using BackdropTemplate
	dd:SetSize(abs(width),24);

	dd.button = CreateFrame("Button",nil,dd);
	dd.button:SetPoint("TOPRIGHT");
	dd.button:SetPoint("BOTTOMRIGHT");
	dd.button:SetWidth(24);
	dd.button:SetHitRectInsets(dd.button:GetWidth() - dd:GetWidth(),0,0,0);
	dd.button:SetScript("OnClick",DropDown_OnClick);

	dd.button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up");
	dd.button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down");
	dd.button:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled");
	dd.button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight");

	dd.label = dd:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
	dd.label:SetPoint("RIGHT",dd.button,"LEFT",-2,0);
	dd.label:SetPoint("LEFT",dd,"LEFT",6,0);
	dd.label:SetJustifyH("RIGHT");
	dd.label:SetWordWrap(false);

	Mixin(dd,DropDownFrameMixin);

	dd:ApplyOurBackdrop(tdd.backdrop);

	-- dropdown display variables
	dd.initFunc = initFunc;
	dd.selectValueFunc = selectValueFunc;

	dd.isAutoSelect = (isAutoSelect == nil and true) or (isAutoSelect);	-- default nil value to true
	dd.isAutoClose = isAutoClose;
	dd.maxShownItems = maxShownItems;
	if (minDropdownWidth) then
		dd.minDropdownWidth = minDropdownWidth;
	elseif (width < 0) then
		dd.minDropdownWidth = abs(width);
	end

	return dd;
end

TippyGaryData.DropDown = tdd;