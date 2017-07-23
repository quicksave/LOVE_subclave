local msgLog = {}

msgLog.new = function ()
    local myfont = love.graphics.newFont(14)

    local mlog = {}
    mlog.totalMessages = 0
    mlog.messagesText = love.graphics.newText(myfont, "default")

    mlog.messagesText:set ( "default" )


    mlog.addMessage = function (string)
        mlog.totalMessages = mlog.totalMessages + 1
        if mlog.totalMessages > 20 then
            mlog.messagesText:clear()
        end

        mlog.messagesText:set ( mlog.messagesText .. "\n" ..  string)

    end


    return mlog
end
