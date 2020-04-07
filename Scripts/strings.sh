#!/bin/sh

swiftgen strings --templatePath "templates/strings.stencil" --param enumName=L10n --output "../leadsbooster/Global/Strings.swift" ../leadsbooster/Base.lproj/Localizable.strings
