function BeStride:DBGet(path,parent)
	local child,nextPath = strsplit(".",path,2)
	
	if child ~= nil and parent ~= nil and parent[child] ~= nil and nextPath == nil then
		return parent[child]
	elseif child ~= nil and parent ~= nil and parent[child] ~= nil and nextPath ~= nil then
		return BeStride:DBGet(nextPath,parent[child])
	elseif child ~= nil and parent == nil and nextPath == nil then
		return self.db.profile[child]
	elseif child ~= nil and parent == nil and nextPath ~= nil then
		if self.db.profile[child] ~= nil then
			return BeStride:DBGet(nextPath,self.db.profile[child])
		else
			BeStride_Debug:Debug("Fatal: self.db.profile[child(" .. child .. ")] == nil")
			return nil
		end
	else
		BeStride_Debug:Debug("Fatal: Unmatch (" .. path .. ")")
		return nil
	end
end

function BeStride:DBSet(path,value,parent)
	local child,nextPath = strsplit(".",path,2)
	
	if child ~= nil and parent ~= nil and nextPath == nil then
		parent[child] = value
	elseif child ~= nil and parent ~= nil and parent[child] == nil and nextPath ~= nil then
		parent[child] = {}
		BeStride:DBSet(nextPath,value,parent[child])
	elseif child ~= nil and parent ~= nil and parent[child] ~= nil and nextPath ~= nil then
		BeStride:DBSet(nextPath,value,parent[child])
	elseif child ~= nil and parent == nil and nextPath == nil then
		self.db.profile[child] = value
	elseif child ~= nil and parent == nil and nextPath ~= nil then
		if self.db.profile[child] == nil then
			self.db.profile[child] = {}
		end
		BeStride:DBSet(nextPath,value,self.db.profile[child])
	end
end

function BeStride:DBGetMount(mountType,mountID)
	if self.db.profile.mounts[mountType][mountID] ~= nil then
		return self.db.profile.mounts[mountType][mountID]
	else
		if self.db.profile.settings.mount.enablenew == nil or (self.db.profile.settings.mount.enablenew ~= nil and self.db.profile.settings.mount.enablenew == true) then
			self.db.profile.mounts[mountType][mountID] = true
		elseif self.db.profile.settings.mount.enablenew ~= nil and self.db.profile.settings.mount.enablenew == false then
			self.db.profile.mounts[mountType][mountID] = false
		end
		return self.db.profile.mounts[mountType][mountID]
	end
end

function BeStride:DBSetMount(mountType,mountID,value)
	self.db.profile.mounts[mountType][mountID] = value
end

function BeStride:DBGetSetting(setting)
	return self:DBGet("settings." .. setting)
end

function BeStride:DBSetSetting(setting, value)
	return self:DBSet("settings." .. setting,value)
end

function BeStride:DBGetClassSetting(parent,setting)
	if parent and self.db.profile.settings.classes[parent] ~= nil and self.db.profile.settings.classes[parent][setting] ~= nil then
		return self.db.profile.settings.classes[parent][setting]
	else
		return nil
	end
end

function BeStride:DBSetClassSetting(parent,setting, value)
	if parent and self.db.profile.settings.classes[parent] ~= nil then
		self.db.profile.settings.classes[parent][setting] = value
	end
end