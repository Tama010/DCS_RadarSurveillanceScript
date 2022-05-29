
function interception()

	-- ユーザーフラグの設定
	-- 開始時にフラグをfalseに設定
	-- 指定したトリガーゾーン内で探知されるとtrueに変更
	local _userFlagList = { "isDetectHostileInZone" }
	-- 例
	--local _userFlagList = { "flagName1", "flagName2", 100, 101 }

	-- デバッグモード
	local _debugMode = true

	local _obj = {}

	local _COALITIONSIDERED = 1
	local _COALITIONSIDEBULE = 2
	local _KEYOFDESIGNATEDEWRGRP = "EWR"
	local _KEYOFAREADEFENCEZONERED = "AirDefenceZone_Red"
	local _KEYOFAREADEFENCEZONEBLUE = "AirDefenceZone_Blue"

	local _KEYOFSCRAMBLE = "SC"

	local _REPETATIONTIME = 5;

	function _obj:start()

		initUserFlag()

		main()

	end

	-- ユーザーフラグを初期化する
	function initUserFlag()

		for _, _flagName in pairs( _userFlagList ) do

			trigger.action.setUserFlag( _flagName , false )

		end


	end
	
	-- 対象オブジェクトのリストを初期化
	function main()

		-- Red、Blueの陣営ごとに処理
		for _coalitionSideNum = _COALITIONSIDERED , _COALITIONSIDEBULE do

			if _coalitionSideNum == _COALITIONSIDERED and _debugMode then
				trigger.action.outText( "陣営 : RED", 3 )
			elseif _coalitionSideNum == _COALITIONSIDEBULE and _debugMode then
				trigger.action.outText( "陣営 : BLUE", 3 )
			end
			

			-- 迎撃に必要なグループとトリガーを取得
			local _ewrList = {}
			
			local _zoneList = {}

			-- 警戒レーダー
			_ewrList = getEWRList( _coalitionSideNum )



			-- 指定したゾーン以内に敵機は存在するか
			_zoneList = getZoneList( _coalitionSideNum )

			local _targetInZoneList = getTargetInZoneList( _ewrList, _zoneList )
			
			-- 対処が必要な場合
			if #_targetInZoneList > 0 then

				if _debugMode then

					trigger.action.outText("    エリア内に敵機を探知", 3)

				end

				local _scrambleList = {}
				local _capList = {}

				_scrambleList = getScrambleList( _coalitionSideNum )

				if #_scrambleList > 0 then

					-- lateActivationをONにする
					orderScramble( _scrambleList )

				end

				-- フラグ操作
				oparationFlag()


			end


		end

		-- 回帰処理
		timer.scheduleFunction( main, self, timer.getTime() + _REPETATIONTIME) 

	end

	-- 警戒レーダーのリストを取得
	function getEWRList( _coalitionSideNum )

		local _ewrList = {}

		for _, _grp in pairs( coalition.getGroups( _coalitionSideNum ) ) do
				
			if string.find( _grp:getName(), _KEYOFDESIGNATEDEWRGRP ) then
			
				table.insert( _ewrList, _grp )

			end

		end

		return _ewrList

	end

	-- スクランブル待機中の機体を取得
	function getScrambleList( _coalitionSideNum )

		local _scrambleList = {}

		for _i, _grp in pairs( coalition.getGroups( _coalitionSideNum ) ) do
				
			if string.find( _grp:getName(), _KEYOFSCRAMBLE ) then
			
				table.insert( _scrambleList, _grp )

			end

		end

		return _scrambleList

	end

	-- スクランブル発進させる
	function orderScramble( _scrambleList )

		for _, _grp in pairs( _scrambleList ) do


			trigger.action.activateGroup(_grp )

		end

	end

	-- ユーザーフラグの操作
	function oparationFlag()

		for _, _flagName in pairs( _userFlagList ) do

			trigger.action.setUserFlag( _flagName , true )

		end

	end

	-- トリガーゾーンのリストを取得
	-- 現状の仕様は1つのみ
	function getZoneList( _coalitionSideNum )

		local _zoneList = {}

		if _coalitionSideNum == _COALITIONSIDERED then

			table.insert( _zoneList, trigger.misc.getZone( _KEYOFAREADEFENCEZONERED ) )

		else

			table.insert( _zoneList, trigger.misc.getZone( _KEYOFAREADEFENCEZONEBLUE ) )

		end

		return _zoneList

	end

	-- ゾーン内に敵機が存在するか確認
	function getTargetInZoneList( _ewrList, _zoneList )

		-- 警戒レーダーが探知した情報をリスト化
		local _targetList = getDetectedTargetByEwr( _ewrList )

		-- デバッグ
		if _debugMode then

			if #_targetList == 0 then
				trigger.action.outText("    探知なし" , 3 )
			end

		end

		-- ターゲットを分析
		return judgeTargetInZone( _targetList, _zoneList );


	end

	-- 警戒レーダーが探知した情報をリスト化
	function getDetectedTargetByEwr( _ewrList )

		local _targetList = {}

		for _, _ewr in pairs( _ewrList ) do

			for _, _unit in pairs( _ewr:getUnits() ) do

				if _unit:getRadar() then

					local _unitController = Unit.getController( _unit )
					
					-- 探知情報を取得
					for _i, _target in pairs( _unitController:getDetectedTargets( Controller.Detection.RADAR, Controller.Detection.VISUAL, Controller.Detection.OPTIC ) ) do

						if _target.distance then

							debagger( _unit , _target )

							if not isInserted( _targetList, _target ) then

								table.insert( _targetList, _target )

							end
							
						end
		
					end

				end

			end	

		end

		return _targetList

	end

	function debagger( _unit , _target )

		if not _debugMode then

			return

		end

		local _sec = 3

		trigger.action.outText("    ユニット名 : ".. _unit:getName().. ", 探知中 : ".. _target.object:getName(), _sec )

	end

	-- 重複チェック
	function isInserted( _targetList, _target )

		for _, _obj in pairs( _targetList ) do

			if _obj == _target then

				return true

			end

		end

		return false

	end

	-- トリガーゾーン内のターゲットのリストを取得
	function judgeTargetInZone( _targetList, _zoneList )

		local _targetInZoneList = {}

		for _, _target in pairs( _targetList ) do

			for _, _zone in pairs( _zoneList ) do

				local _targetPos = _target.object:getPoint()
				local _zonePos = _zone.point

				local _distance = math.sqrt( ( _targetPos.x - _zonePos.x )^2 + ( _targetPos.z - _zonePos.z )^2 )

				-- トリガーゾーン内か判断
				if _distance < _zone.radius then

					table.insert( _targetInZoneList, _target )

				end

			end

		end

		return _targetInZoneList

	end

	return _obj

end

_instance = interception() -- インスタンス生成
_instance.start() -- 処理開始